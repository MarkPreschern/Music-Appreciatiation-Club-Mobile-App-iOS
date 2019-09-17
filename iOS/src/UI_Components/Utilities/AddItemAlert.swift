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
            let params: Parameters = [
                "item_is_album": item.type == ItemType.ALBUM ? 1 : 0,
                "item_name": item.name,
                "item_artist": item.artist,
                "item_spotify_id": item.spotify_id
            ]
            // creates the song item and pick
            sender.macRequest(urlName: "pick", httpMethod: .post, params: params, callback: { response -> Void in
                // macRequest handles errors, so nothing more is needed to be done
            })
        }))
        // presents the alert
        sender.present(self, animated: true, completion: nil)
    }
}
