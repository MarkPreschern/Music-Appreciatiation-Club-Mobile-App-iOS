//
//  DeleteRole.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/29/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Represents a role
struct RoleData {
    let name : String!
    let description: String!
    let id : Int!
}

class DeleteRole: UIViewController, PopupScreen, UITableViewDelegate {
    
    var roles = [RoleData]()
    
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
        
        self.loadRoleData()
    }
    
    // determines what role's the user can pick from and reloads the table data
    func loadRoleData() {
        self.macRequest(urlName: "roles", httpMethod: .get, header: nil, successAlert: false, attempt: 0, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["roles"] as? [JSONStandard] {
                        for i in 0..<items.count {
                            let item = items[i]
                            
                            let role = RoleData(
                                name: item["name"] as? String,
                                description: item["description"] as? String,
                                id: item["role_id"] as? Int)
                            
                            // appends the role depending on the user's access
                            if (userData.access_name == "Admin" || userData.access_name == "Developer") && role.name != "Member" {
                                self.roles.append(role)
                            }
                            
                            if i == items.count - 1 {
                                self.table_outlet.reloadData()
                            }
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate items",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    // when the cancel button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when table view cell is tapped, prompt the current user to delete the role
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Delete Role", message: "Are you sure you want to delete role " + roles[indexPath.row].name! + "?", preferredStyle: UIAlertController.Style.alert)
        // handles if the user clicks "no"
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        // handles if the user clicks "yes"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let header: HTTPHeaders = [
                "role_id": String(self.roles[indexPath.row].id!),
            ]
            
            self.showSpinner(onView: self.view)
            self.macRequest(urlName: "deleteRole", httpMethod: .post, header: header, successAlert: false, attempt: 0, callback: { jsonData -> Void in
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
extension DeleteRole: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roles.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roleCell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.roles[indexPath.row].name! + ", " + self.roles[indexPath.row].description!
                
        return cell ?? UITableViewCell()
    }
}
