//
//  DeleteItemAlert.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

extension UIAlertController {
    
    // displays an alert for adding this item, and asks the user to confirm or cancel their action
    func deleteItemAlert(pick: Pick, type: ItemType, sender: UIViewController, callback: @escaping (String) -> Void) {
        self.title = "Delete " + type.toString as String
        self.message = "Delete " + pick.itemData.name + " from your event " + type.toString.lowercased() + " picks?"
        // handles if the user clicks "no"
        self.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert: UIAlertAction!) in
            callback("Failure")
        }))
        // handles if the user clicks "yes"
        self.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
            let header: HTTPHeaders = [
                "pick_id": String(pick.pickID),
                "item_id": String(pick.itemData.spotify_id)
            ]
            // creates the item and pick
            sender.macRequest(urlName: "deletePick", httpMethod: .post, header: header, successAlert: true, callback: { response -> Void in
                callback("Success")
            })
        }))
        // presents the alert
        sender.present(self, animated: true, completion: nil)
    }
}
