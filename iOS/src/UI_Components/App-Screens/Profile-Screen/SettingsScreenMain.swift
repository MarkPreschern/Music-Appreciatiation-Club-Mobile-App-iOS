//
//  SettingsScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/11/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// represents a pick as it's pick id, the item picked, the votes for this item, and the user that picked this item
struct Setting {
    let name: String!
    var popup: PopupScreen!
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
            settings.append(Setting(name: "Log Out", popup: LogOut()))
            callback("Done")
        }
        if access == "Moderator" {
            settings.append(Setting(name: "Log Out", popup: LogOut()))
            callback("Done")
        }
        if access == "Admin" {
            settings.append(Setting(name: "Log Out", popup: LogOut()))
            callback("Done")
        }
        if access == "Developer" {
            settings.append(Setting(name: "Log Out", popup: LogOut()))
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
        let popOverVC = settings[indexPath.row].popup!
        popOverVC.modalPresentationStyle = .overCurrentContext
        popOverVC.modalTransitionStyle = .crossDissolve
        self.present(popOverVC, animated: true, completion: nil)
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
