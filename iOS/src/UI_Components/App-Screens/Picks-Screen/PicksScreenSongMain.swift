//
//  PicksScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// represents a pick as it's pick id, the item picked, the votes for this item, and the user that picked this item
struct Pick {
    let pickID: Int!
    let itemData: ItemData!
    let voteData: VoteData!
    let userData: UserData!
}

// represents a vote for a pick
struct VoteData {
    let totalVotes: Int! // upVotes - downvotes
    let upVoteData: JSONStandard!
    let downVoteData: JSONStandard!
}

// Represents the picks screen. Holds information regarding:
// - continously updated song top picks across the entire club
// - ability to vote on songs and albums
class PicksScreenSongMain: UIViewController, UITableViewDelegate {
    
    // user picked songs and their votes
    var userSongPicks = [Pick]()
    // club picked songs and their votes
    var clubSongPicks = [Pick]()
    
    // cell's containing club songs
    var clubSongCells = [SongCell]()

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
        self.myPicksTable_outlet.delegate = self

        self.clubPicksTable_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.clubPicksTable_outlet.dataSource = self
        self.clubPicksTable_outlet.delegate = self

        self.requestUserAndClubSongData()
    }
    
    // requests user and club song data from mac api
    func requestUserAndClubSongData() {
        self.showSpinner(onView: self.view)
        self.requestUserData(callback: { (response1) -> Void in
            if (response1 == "Error") {
                self.removeSpinner()
            } else if (response1 == "Done") {
                self.requestClubData(callback: { (response2) -> Void in
                    if (response2 == "Error") {
                        self.removeSpinner()
                    } else if (response2 == "Done") {
                        if (self.userSongPicks.count > 0) {
                            self.myPicksTable_outlet.reloadData()
                            self.myPicksTable_outlet.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        if (self.clubSongPicks.count > 0) {
                            self.clubPicksTable_outlet.reloadData()
                            self.clubPicksTable_outlet.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        self.removeSpinner()
                    }
                })
            }
        })
    }
    
    // requests user song data from the mac api
    func requestUserData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "userSongPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            self.parsePickData(jsonData: jsonData, callback: { (picks : [Pick]?) -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    if (picks == nil) {
                        callback("Error")
                    } else if (picks![0].itemData == nil) {
                        self.userSongPicks = []
                        callback("Done")
                    } else {
                        self.userSongPicks = picks!
                        callback("Done")
                    }
                }
            })
        })
    }
    
    // requests club song data from the mac api
    func requestClubData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "clubSongPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            self.parsePickData(jsonData: jsonData, callback: { (picks : [Pick]?) -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    if (picks == nil) {
                        callback("Error")
                    } else if (picks![0].itemData == nil) {
                        self.userSongPicks = []
                        callback("Done")
                    } else {
                        self.clubSongPicks = picks!
                        callback("Done")
                    }
                }
            })
        })
    }
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.restorationIdentifier == "MySongPicksTable") {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "songViewID") as? SongView
            nextVC!.songData = userSongPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "picksScreenSongID"
            self.present(nextVC!, animated:true, completion: nil)
        } else if (tableView.restorationIdentifier == "ClubSongPicksTable") {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "songViewID") as? SongView
            nextVC!.songData = clubSongPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "picksScreenSongID"
            self.present(nextVC!, animated:true, completion: nil)
        }
    }
    
    // handles an up vote click
    @objc func upVote(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
    
            
            // TODO:
            // - if currently upVote, delete the upVote
            // - if currently downVote, delete the downVote and add the upVote
            // - if currently nothing, add the upVote
            // - update the UI accordingly
            
            let index = (gesture as! VoteTapGesture).index
            let header: HTTPHeaders = [
                "pick_id": String(userSongPicks[index].pickID),
                "up": "1",
                "comment": ""
            ]
            self.macRequest(urlName: "vote", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    // TODO update UI
                }
            })
        }
    }
    
    // handles a down vote click
    @objc func downVote(gesture: UIGestureRecognizer) {
        
        // TODO:
        // - if currently downVote, delete the downVote
        // - if currently upVote, delete the upVote and add the downVote
        // - if currenlty nothing, add the downVote
        // - update the UI accordingly
        
        if (gesture.view as? UIImageView) != nil {
            
            let index = (gesture as! VoteTapGesture).index
            let header: HTTPHeaders = [
                "pick_id": String(userSongPicks[index].pickID),
                "up": "0",
                "comment": ""
            ]
            self.macRequest(urlName: "vote", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    // TODO: Update UI
                }
            })
        }
    }
    
    
}

// extension handles table data
extension PicksScreenSongMain: UITableViewDataSource {
        
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.restorationIdentifier == "MySongPicksTable") {
            return userSongPicks.count
        } else if (tableView.restorationIdentifier == "ClubSongPicksTable") {
            self.clubSongCells = [SongCell]()
            self.clubSongCells.reserveCapacity(clubSongPicks.count)
            for _ in 0..<self.clubSongPicks.count {
                self.clubSongCells.append(SongCell())
            }
            return clubSongPicks.count
        } else {
            return 0
        }
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.restorationIdentifier == "MySongPicksTable") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mySongsCell") as! SongCell
            //sets the label
            let mainLabel = cell.viewWithTag(1) as! UILabel
            mainLabel.text = userSongPicks[indexPath.row].itemData.name
            //sets the image
            let mainImageView = cell.viewWithTag(2) as! UIImageView
            mainImageView.image = userSongPicks[indexPath.row].itemData.image
            // sets the vote label
            let voteLabel = cell.viewWithTag(4) as! UILabel
            voteLabel.text = String(userSongPicks[indexPath.row].voteData.totalVotes ?? 0)
            
            return cell
        } else if (tableView.restorationIdentifier == "ClubSongPicksTable") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clubSongsCell") as! SongCell
            //sets the label
            let mainLabel = cell.viewWithTag(1) as! UILabel
            mainLabel.text = clubSongPicks[indexPath.row].itemData.name
            //sets the image
            let mainImageView = cell.viewWithTag(2) as! UIImageView
            mainImageView.image = clubSongPicks[indexPath.row].itemData.image
            // sets the name label
            let nameLabel = cell.viewWithTag(3) as! UILabel
            nameLabel.text = clubSongPicks[indexPath.row].userData.user_name
            // sets the vote label
            let voteLabel = cell.viewWithTag(4) as! UILabel
            voteLabel.text = String(clubSongPicks[indexPath.row].voteData.totalVotes ?? 0)
            
            // creates up vote image gesture recognizers
            let tapGestureUp = VoteTapGesture(target: self, action: #selector(PicksScreenSongMain.upVote(gesture:)))
            tapGestureUp.index = indexPath.row
            cell.upVote_outlet.addGestureRecognizer(tapGestureUp)
            cell.upVote_outlet.isUserInteractionEnabled = true
            
            // creates down vote image gesture recognizers
            let tapGestureDown = VoteTapGesture(target: self, action: #selector(PicksScreenSongMain.downVote(gesture:)))
            tapGestureDown.index = indexPath.row
            cell.downVote_outlet.addGestureRecognizer(tapGestureDown)
            cell.downVote_outlet.isUserInteractionEnabled = true
            
            self.clubSongCells[indexPath.row] = cell
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// custom table cell containing song vote outlets
class SongCell: UITableViewCell {
    @IBOutlet weak var upVote_outlet: UIImageView!
    @IBOutlet weak var downVote_outlet: UIImageView!
}

// custom tap gesture wtih the index of the table column
class VoteTapGesture: UITapGestureRecognizer {
    var index = Int()
}
