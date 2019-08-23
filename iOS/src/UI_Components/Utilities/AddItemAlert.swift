//
//  AddItemAlert.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/22/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    // displays an alert for adding this item, and asks the user to confirm or cancel their action
    func addItemAlert(name: String, type: ItemType, item: ItemData, sender: UIViewController) {
        self.title = "Add " + type.toString as String
        self.message = "Add " + name + " to your weekly " + type.toString.lowercased() + " picks?"
        // handles if the user clicks "no"
        self.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        // handles if the user clicks "yes"
        self.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            switch type {
            case .SONG:
                print("Song Added")
            //TODO : Query to database the number of songs already in this users top weekly picks. if greater than the maximum allowed value, than show another alert indicating failure and why
            case .ALBUM:
                print("Album Added")
                //TODO : Query to database the number of albums already in this users top weekly picks. if greater than the maximum allowed value, than show another alert indicating failure and why
            }
        }))
        // presents the alert
        sender.present(self, animated: true, completion: nil)
    }
}
