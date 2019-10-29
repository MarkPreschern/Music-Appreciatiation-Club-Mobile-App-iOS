//
//  SettingsScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/11/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// represents a setting as it's name, popup View Controller, and Storyboard Identifier
struct Setting {
    let name: String!
    let popup: PopupScreen!
    let identifier: String!
}

// All possible user settings
var settings = [Setting]()

// Represents user settings
class SettingsScreenMain: UIViewController, UITableViewDelegate {
    
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
        
        if settings.count == 0 {
            self.loadSettings(callback: { response -> Void in
                if response == "Done" {
                    self.table_outlet.reloadData()
                }
            })
        } else {
            self.table_outlet.reloadData()
        }
    }
    
    // loads in user settings based on their access
    func loadSettings(callback: @escaping (String) -> Void) {
        let access = userData.access_name
        
        if access == "User" {
            settings.append(Setting(name: "Log Out", popup: LogOut(), identifier: nil))
            callback("Done")
        }
        if access == "Moderator" {
            settings.append(Setting(name: "Add User", popup: AddUser(), identifier: "AddUserID"))
            settings.append(Setting(name: "Delete User", popup: DeleteUser(), identifier: "DeleteUserID"))
            settings.append(Setting(name: "Log Out", popup: LogOut(), identifier: nil))
            callback("Done")
        }
        if access == "Admin" || access == "Developer" {
            settings.append(Setting(name: "Add User", popup: AddUser(), identifier: "AddUserID"))
            settings.append(Setting(name: "Delete User", popup: DeleteUser(), identifier: "DeleteUserID"))
            settings.append(Setting(name: "Add Role", popup: AddRole(), identifier: "AddRoleID"))
            settings.append(Setting(name: "Delete Role", popup: DeleteRole(), identifier: "DeleteRoleID"))
            settings.append(Setting(name: "Log Out", popup: LogOut(), identifier: nil))
            callback("Done")
        }
    }

    // returns to the profile screen when clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "profileScreenID")
        self.present(nextVC, animated:true, completion: nil)
    }
    
    // when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (settings[indexPath.row].name == "Log Out") {
            let popOverVC = settings[indexPath.row].popup!
            self.present(popOverVC, animated: true, completion: nil)
        } else {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: settings[indexPath.row].identifier)
            self.present(nextVC, animated:true, completion: nil)
        }
    }
}

// extension handles table data
extension SettingsScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell")
        
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = settings[indexPath.row].name
        
        return cell ?? UITableViewCell()
    }
}
