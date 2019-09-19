//
//  AddItemAlert.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/22/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

extension UIAlertController {
    
    // displays an alert for adding this item, and asks the user to confirm or cancel their action
    func addItemAlert(name: String, type: ItemType, item: ItemData, sender: UIViewController) {
        self.title = "Add " + type.toString as String
        self.message = "Add " + name + " to your weekly " + type.toString.lowercased() + " picks?"
        // handles if the user clicks "no"
        self.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        // handles if the user clicks "yes"
        self.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
            let header: HTTPHeaders = [
                "item_id": item.spotify_id,
                "item_is_album": item.type == ItemType.ALBUM ? "1" :"0",
                "item_name": item.name,
                "item_artist": item.artist
            ]
            // creates the item and pick
            sender.macRequest(urlName: "pick", httpMethod: .post, header: header, callback: { response -> Void in
                // TODO: alert of success
            })
        }))
        // presents the alert
        sender.present(self, animated: true, completion: nil)
    }
}
