//
//  MembersScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/11/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents a screen containing all members of the Music Appreciation Club
class MembersScreenMain: UIViewController, UITableViewDelegate {
    
    // relevent user data for all users except for the one currently using the app
    var users = [UserData]() //MAKE GLOBAL
    
    @IBOutlet weak var table_outlet: UITableView!
    @IBOutlet weak var view_outlet: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets view border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets table outlet's datasource to this class's extension
        self.table_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.table_outlet.dataSource = self
        self.table_outlet.delegate = self
        
        self.retrieveUserData();
    }
    
    // retrieves user data from the MAC API
    func retrieveUserData() {
        self.showSpinner(onView: self.view)
        self.macRequest(urlName: "users", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["users"] as? [JSONStandard] {
                        if items.count == 0 {
                            self.removeSpinner()
                        }
                        for i in 0..<items.count {
                            let item = items[i]
                            // TODO: Confirm image decoding works as expected
                            let imageEncoded = item["image_data"] as? String
                            let mainImageData = imageEncoded == nil ? nil : NSData(base64Encoded: imageEncoded!, options: .init())
                            let mainImage = imageEncoded == nil ? nil : UIImage(data: mainImageData! as Data)
                            
                            let user = UserData(user_id: item["user_id"] as? Int,
                                                user_name: item["user_name"] as? String,
                                                user_nuid: nil,
                                                authorization_token: nil,
                                                role_id: nil,
                                                access_id: nil,
                                                role_name: item["role_name"] as? String,
                                                role_description: item["description"] as? String,
                                                access_name: nil,
                                                access_description: nil,
                                                image_data: imageEncoded == nil ? nil : mainImage)
                            
                            self.users.append(user)
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
    
    // returns to the profile screen when clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "profileScreenID")
        self.present(nextVC, animated:true, completion: nil)
    }
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "profileScreenID") as! ProfileScreenMain
        nextVC.currentUser = false
        nextVC.userDetails = self.users[indexPath.row]
        self.present(nextVC, animated:true, completion: nil)
    }
}

// extension handles table data
extension MembersScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "membersCell")
        
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.users[indexPath.row].user_name
        
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
