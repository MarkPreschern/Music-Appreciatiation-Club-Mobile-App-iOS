//
//  AddUser.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/24/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// delete a user from the app
class DeleteUser: UIViewController, PopupScreen, UITableViewDelegate {
    
    // relevent user data for all users except for the one currently using the app
    var users = [UserData]()
    
    @IBOutlet weak var header_outlet: UILabel!
    @IBOutlet weak var table_outlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets header border
        self.header_outlet.layer.borderWidth = 1
        self.header_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets table outlet's datasource to this class's extension
        self.table_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.table_outlet.dataSource = self
        self.table_outlet.delegate = self
        
        self.loadUserData()
    }
    
    // loads in all user data except for the current user using the app
    func loadUserData() {
        self.showSpinner(onView: self.view, clickable: false)
        self.macRequest(urlName: "users", httpMethod: .get, header: [:], successAlert: false, attempt: 0, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["users"] as? [JSONStandard] {
                        if items.count == 0 {
                            self.removeSpinner()
                        }
                        for i in 0..<items.count {
                            let item = items[i]
                            // TODO: Confirm image decoding works as expected
                            let imageEncoded = (item["image_data"] as? String)?.removingPercentEncoding
                            let mainImageData = imageEncoded == nil ? nil : NSData(base64Encoded: imageEncoded!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                            let mainImage = imageEncoded == nil ? nil : UIImage(data: mainImageData! as Data)!
                            
                            let user = UserData(user_id: item["user_id"] as? Int,
                                                user_name: item["user_name"] as? String,
                                                user_nuid: nil,
                                                authorization_token: nil,
                                                role_id: nil,
                                                access_id: nil,
                                                role_name: item["role_name"] as? String,
                                                role_description: item["description"] as? String,
                                                access_name: item["access_name"] as? String,
                                                access_description: nil,
                                                image_data: imageEncoded == nil ? nil : mainImage)
                            
                            // dictates which users this user can delete
                            if userData.access_name == "Developer" {
                                self.users.append(user)
                            } else if userData.access_name == "Admin" && (user.access_name == "User" || user.access_name == "Moderator") {
                                self.users.append(user)
                            } else if userData.access_name == "Moderator" && user.access_name == "User" {
                                self.users.append(user)
                            }
                            
                            if i == items.count - 1 {
                                self.table_outlet.reloadData()
                                self.removeSpinner()
                            }
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate items",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                        self.removeSpinner()
                    }
                } else {
                    self.removeSpinner()
                }
            } else {
                self.removeSpinner()
            }
        })
    }
    
    // when the cancel button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when table view cell is tapped, prompt the current user to delete the user
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Delete User", message: "Are you sure you want to delete user " + users[indexPath.row].user_name! + "?", preferredStyle: UIAlertController.Style.alert)
        // handles if the user clicks "no"
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        // handles if the user clicks "yes"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let header: HTTPHeaders = [
                "delete_user_id": String(self.users[indexPath.row].user_id!),
            ]
            
            self.showSpinner(onView: self.view, clickable: false)
            self.macRequest(urlName: "deleteUser", httpMethod: .post, header: header, successAlert: false, attempt: 0, callback: { jsonData -> Void in
                if let statusCode = jsonData?["statusCode"] as? String {
                    if statusCode == "200" {
                        let alert = UIAlertController(
                        title: "Success",
                        message: jsonData?["message"] as? String,
                        preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(
                        title: "Close",
                        style: UIAlertAction.Style.default,
                        handler: { (alert: UIAlertAction!) in
                            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsScreenID")
                            self.present(nextVC, animated: false, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.removeSpinner()
                    }
                } else {
                    self.removeSpinner()
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// extension handles table data
extension DeleteUser: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deleteUserCell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.users[indexPath.row].user_name! + ", " + self.users[indexPath.row].role_name!
        //sets the image
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        if self.users[indexPath.row].image_data == nil {
            mainImageView.image = UIImage(named: "default-profile-image")
        } else {
            mainImageView.image = self.users[indexPath.row].image_data
        }
                
        return cell ?? UITableViewCell()
    }
}
