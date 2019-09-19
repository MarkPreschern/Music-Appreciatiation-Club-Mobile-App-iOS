//
//  PicksScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the picks screen. Holds information regarding:
// - continously updated song top picks across the entire club
// - ability to vote on songs and albums
class PicksScreenSongMain: UIViewController {
    
    // user picked songs
    var picksUserSongItems = [ItemData]()
    // club picked songs
    var picksClubSongItems = [ItemData]()

    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var songLabel_outlet: UIButton!
    @IBOutlet weak var albumLabel_outlet: UIButton!
    @IBOutlet weak var myPicksView_outlet: UIView!
    @IBOutlet weak var clubPicksView_outlet: UIView!
    
    @IBOutlet weak var myPicksTable_outlet: UITableView!
    @IBOutlet weak var clubPicksTable_outlet: UITableView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()

        //sets task bar border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets myPicks and clubPicks borders
        self.myPicksView_outlet.layer.borderWidth = 1
        self.myPicksView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        self.clubPicksView_outlet.layer.borderWidth = 1
        self.clubPicksView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets task song and album borders just on the top and bottom
        self.songLabel_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.songLabel_outlet.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.albumLabel_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.albumLabel_outlet.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        
        //sets song and album button colors
        self.songLabel_outlet.backgroundColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 0.5)
        self.albumLabel_outlet.backgroundColor = UIColor.white
        
        //sets table outlet's datasource to this class's extension
        self.myPicksTable_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.myPicksTable_outlet.dataSource = self
        self.clubPicksTable_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.clubPicksTable_outlet.dataSource = self
        
        self.requestUserAndClubSongData()
    }
    
    // requests user and club song data from mac api
    func requestUserAndClubSongData() {
        self.showSpinner(onView: self.view)
        self.requestUserData(callback: { (response1) -> Void in
            if (response1 == "Done") {
                self.requestClubData(callback: { (response2) -> Void in
                    if (response2 == "Done") {
                        self.removeSpinner()
                    }
                })
            }
        })
    }
    
    // requests user song data from the mac api
    func requestUserData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "userSongPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if (jsonData!["statusCode"]?.stringValue == "200") {
                let songs = jsonData!["songs"] as! [JSONStandard]
                for i in 0..<songs.count {
                    let song = songs[i]
                    // TODO: get all song data in picksUserSongItems
                }
            }
        })
    }
    
    // requests club song data from the mac api
    func requestClubData(callback: @escaping (String) -> Void) {
        // TODO
    }
}

// extension handles table data
extension PicksScreenSongMain: UITableViewDataSource {
        
        //sets the number of rows in the table view
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if (tableView.restorationIdentifier == "MySongPicksTable") {
                return picksUserSongItems.count
            } else if (tableView.restorationIdentifier == "ClubSongPicksTable") {
                return picksClubSongItems.count
            } else {
                return 0
            }
        }
        
        //updates table view data including the image and label
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if (tableView.restorationIdentifier == "MySongPicksTable") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mySongsCell")
                //sets the label
                let mainLabel = cell?.viewWithTag(1) as! UILabel
                mainLabel.text = picksUserSongItems[indexPath.row].name
                //sets the image
                let mainImageView = cell?.viewWithTag(2) as! UIImageView
                mainImageView.image = picksUserSongItems[indexPath.row].image
                return cell!
            } else if (tableView.restorationIdentifier == "ClubSongPicksTable") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "clubSongsCell")
                //sets the label
                let mainLabel = cell?.viewWithTag(1) as! UILabel
                mainLabel.text = picksClubSongItems[indexPath.row].name
                //sets the image
                let mainImageView = cell?.viewWithTag(2) as! UIImageView
                mainImageView.image = picksClubSongItems[indexPath.row].image
                return cell!
            } else {
                return UITableViewCell()
            }
        }
}
