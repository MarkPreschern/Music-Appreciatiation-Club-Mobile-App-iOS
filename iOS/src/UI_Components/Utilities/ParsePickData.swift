//
//  ParsePickData.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 9/20/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

extension UIViewController {

    // parses pick data for songs and votes
    func parsePickData(jsonData : JSONStandard!, table: UITableView!, callback: @escaping ([Pick]?) -> Void) {
        var picks = [Pick]()
        
        if let items = jsonData!["items"] as? [JSONStandard] {
            if (items.count == 0) {
                let pick = Pick(
                    pickID: nil,
                    itemData: nil,
                    voteData: nil,
                    userData: nil)
                picks.append(pick)
                callback(picks)
            } else {
                for i in 0..<items.count {
                    let item = items[i]
                    if let votes = item["votes"] as? JSONStandard {
                        let imageUrl = item["item_image_url"] as! String
                        let mainImageData = NSData(contentsOf: URL(string: imageUrl)!)
                        let mainImage = UIImage(data: mainImageData! as Data)
                        
                        let pick = Pick(
                            pickID: item["pick_id"] as? Int,
                            itemData: ItemData(
                                type: (item["is_album"] as? Int) == 1 ? ItemType.ALBUM : ItemType.SONG,
                                name: item["item_name"] as? String,
                                artist: item["item_artist"] as? String,
                                image: mainImage,
                                imageUrl: imageUrl,
                                spotify_id: item["item_id"] as? String,
                                previewUrl: item["item_preview_url"] as? String),
                            voteData: VoteData(
                                totalVotes: votes["totalVotes"] as? Int,
                                upVoteData: votes["upVoteData"] as? JSONStandard,
                                downVoteData: votes["downVoteData"] as? JSONStandard,
                                userVoteID: nil),
                            userData: UserData(
                                user_id: item["user_id"] as? Int,
                                user_name: item["name"] as? String,
                                user_nuid: nil,
                                authorization_token: nil,
                                role_id: nil,
                                access_id: nil,
                                role_name: nil,
                                role_description: nil,
                                access_name: nil,
                                access_description: nil,
                                image_data: nil))
                        picks.append(pick)
                        DispatchQueue.main.async {
                            table.reloadData()
                        }
                        if (i == items.count - 1) {
                            callback(picks)
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate item votes",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                        callback(nil)
                    }
                }
            }
        } else {
            let alert = createAlert(
                title: "Request Failed",
                message: "Error occured during request, couldn't locate items",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
            callback(nil)
        }
    }
}
