//
//  PicksScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the picks screen. Holds information regarding:
// - continously updated album top picks across the entire club
// - ability to vote on songs and albums
class PicksScreenAlbumMain: UIViewController, UITableViewDelegate {
    
    // user picked songs
    var userAlbumPicks = [Pick]()
    // club picked songs
    var clubAlbumPicks = [Pick]()
    
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
        self.songLabel_outlet.backgroundColor = UIColor.white
        self.albumLabel_outlet.backgroundColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 0.5)
        
        //sets table outlet's datasource to this class's extension
        self.myPicksTable_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.myPicksTable_outlet.dataSource = self
        self.myPicksTable_outlet.delegate = self
        
        self.clubPicksTable_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.clubPicksTable_outlet.dataSource = self
        self.clubPicksTable_outlet.delegate = self
        
        self.requestUserAndClubAlbumData()
    }
    
    // requests user and club album data from mac api
    func requestUserAndClubAlbumData() {
        self.showSpinner(onView: self.view)
        self.requestUserData(callback: { (response1) -> Void in
            if (response1 == "Error") {
                self.removeSpinner()
            } else if (response1 == "Done") {
                self.requestClubData(callback: { (response2) -> Void in
                    if (response2 == "Error") {
                        self.removeSpinner()
                    } else if (response2 == "Done") {
                        if (self.userAlbumPicks.count > 0) {
                            self.myPicksTable_outlet.reloadData()
                            self.myPicksTable_outlet.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        if (self.clubAlbumPicks.count > 0) {
                            self.clubPicksTable_outlet.reloadData()
                            self.clubPicksTable_outlet.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        self.removeSpinner()
                    }
                })
            }
        })
    }
    
    // requests user album data from the mac api
    func requestUserData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "userAlbumPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            self.parsePickData(jsonData: jsonData, callback: { (picks : [Pick]?) -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    if (picks == nil) {
                        callback("Error")
                    } else if (picks![0].itemData == nil) {
                        self.userAlbumPicks = []
                        callback("Done")
                    } else {
                        self.userAlbumPicks = picks!
                        callback("Done")
                    }
                }
            })
        })
    }
    
    // requests club album data from the mac api
    func requestClubData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "clubAlbumPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            self.parsePickData(jsonData: jsonData, callback: { (picks : [Pick]?) -> Void in
                if (jsonData?["statusCode"] as? String == "200") {
                    if (picks == nil) {
                        callback("Error")
                    } else if (picks![0].itemData == nil) {
                        self.userAlbumPicks = []
                        callback("Done")
                    } else {
                        self.clubAlbumPicks = picks!
                        callback("Done")
                    }
                }
            })
        })
    }
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.restorationIdentifier == "MyAlbumPicksTable") {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? AlbumView
            nextVC!.albumData = userAlbumPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "picksScreenAlbumID"
            self.present(nextVC!, animated:true, completion: nil)
        } else if (tableView.restorationIdentifier == "ClubAlbumPicksTable") {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? AlbumView
            nextVC!.albumData = clubAlbumPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "picksScreenAlbumID"
            self.present(nextVC!, animated:true, completion: nil)
        }
    }
    
}

// extension handles table data
extension PicksScreenAlbumMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.restorationIdentifier == "MyAlbumPicksTable") {
            return userAlbumPicks.count
        } else if (tableView.restorationIdentifier == "ClubAlbumPicksTable") {
            return clubAlbumPicks.count
        } else {
            print("here")
            return 0
        }
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.restorationIdentifier == "MyAlbumPicksTable") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myAlbumsCell")
            //sets the label
            let mainLabel = cell?.viewWithTag(1) as! UILabel
            mainLabel.text = userAlbumPicks[indexPath.row].itemData.name
            //sets the image
            let mainImageView = cell?.viewWithTag(2) as! UIImageView
            mainImageView.image = userAlbumPicks[indexPath.row].itemData.image
            // sets the name label
            let nameLabel = cell?.viewWithTag(3) as! UILabel
            nameLabel.text = userAlbumPicks[indexPath.row].userData.user_name
            // sets the vote label
            let voteLabel = cell?.viewWithTag(4) as! UILabel
            voteLabel.text = String(userAlbumPicks[indexPath.row].voteData.totalVotes ?? 0)
            return cell!
        } else if (tableView.restorationIdentifier == "ClubAlbumPicksTable") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clubAlbumsCell")
            //sets the label
            let mainLabel = cell?.viewWithTag(1) as! UILabel
            mainLabel.text = clubAlbumPicks[indexPath.row].itemData.name
            //sets the image
            let mainImageView = cell?.viewWithTag(2) as! UIImageView
            mainImageView.image = clubAlbumPicks[indexPath.row].itemData.image
            // sets the name label
            let nameLabel = cell?.viewWithTag(3) as! UILabel
            nameLabel.text = clubAlbumPicks[indexPath.row].userData.user_name
            // sets the vote label
            let voteLabel = cell?.viewWithTag(4) as! UILabel
            voteLabel.text = String(clubAlbumPicks[indexPath.row].voteData.totalVotes ?? 0)
            return cell!
        } else {
            return UITableViewCell()
        }
    }
}

