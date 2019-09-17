//
//  AlbumView.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/2/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

var songs = [ItemData]() // list of songs in the table view

// Represents an album view, containing information about the album and it's songs
class AlbumView: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var name_outlet: UILabel!
    @IBOutlet weak var image_outlet: UIImageView!
    @IBOutlet weak var imageBackground_outlet: UIImageView!
    @IBOutlet weak var backButton_outlet: UIButton!
    @IBOutlet weak var addButton_outlet: UIButton!
    
    @IBOutlet weak var tableView_outlet: UITableView!
    
    var albumData: ItemData! // the album data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets song image and name information in view
        self.name_outlet.text = self.albumData.name
        self.image_outlet.image = self.albumData.image
        self.imageBackground_outlet.image = self.albumData.image.averageColor()!.image(self.albumData.image.size)
        
        // makes back and add button's background color transparent
        self.backButton_outlet.backgroundColor = UIColor.clear
        self.addButton_outlet.backgroundColor = UIColor.clear
        
        //sets table view constraints
        self.tableView_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView_outlet.dataSource = self
        self.tableView_outlet.delegate = self
        
        //determines the color (black/white) of text and buttons based on the song image
        let color = self.albumData.image.averageColor()!.colorByBrightness()
        self.backButton_outlet.setTitleColor(color, for: UIControl.State.normal)
        self.addButton_outlet.setTitleColor(color, for: UIControl.State.normal)
        self.name_outlet.textColor = color
        
        //loads the songs in this album if not already populated
        if (songs.count == 0) {
            self.showSpinner(onView: self.view)
            self.callSpotifyAlbumSongs(id: self.albumData.spotify_id, completion: { (callback) -> Void in
                if (callback == "Complete") {
                    self.removeSpinner()
                }
            })
        }
    }
    
    //calls to spotify api for songs and albums of this query and updates table
    func callSpotifyAlbumSongs(id : String!, completion: @escaping (String) -> Void) {
        
        // builds url using the album id
        let url = self.buildAlbumSongsURL(id: id)
        songs = [ItemData]() //resets table to empty
        
        // calls the spotify url, waiting for callbacks of success before moving to next steps
        self.callSpotifyURL(url: url!, callback: { (callback) -> Void in
            if (callback == "Success") {
                // reloads table view data and scrolls to top of table view
                DispatchQueue.main.sync {
                    self.tableView_outlet.reloadData()
                    self.tableView_outlet.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    completion("Complete")
                }
            }
        })
    }
    
    //builds the url for querying all songs in this album
    func buildAlbumSongsURL(id : String!) -> String! {
        return "https://api.spotify.com/v1/albums/" + id + "/tracks?market=US" 
    }
    
    //calls the spotify url
    func callSpotifyURL(url : String, callback: @escaping (String) -> Void) {
        //callback handler is needed to get the authorization since requestSpotifyAuthorizationToken is asyncronous
        self.requestSpotifyAuthorizationToken(callback: { (token) -> Void in
            if (token == "Error") {
                fatalError()
            } else {
                //header information for spotify url call
                let headers : HTTPHeaders = [
                    "Accept" : "application/json",
                    "Content-Type" : "application/json",
                    "Authorization" : token
                ]
                
                Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
                    response in
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.parseSpotifyData(JSONData: response.data!, completion: { (completion) -> Void in
                            if (completion == "Success") {
                                callback("Success")
                            }
                        })
                    }
                })
            }
        })
    }
    
    //requests an authorization token from spotify, and sets it to the 'Authorization' header
    func requestSpotifyAuthorizationToken(callback: @escaping (String) -> Void) {
        let url = "https://accounts.spotify.com/api/token"
        let parameters = ["client_id" : "f6412fd4b4cc4d59a043a432c377ed19",
                          "client_secret" : "b64be84293c24dfdabf2be9e1cd07f53",
                          "grant_type" : "client_credentials"]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                let access_token = readableJSON["access_token"] as! String
                let token_type = readableJSON["token_type"] as! String
                callback(token_type + " " + access_token)
            } catch {
                print("Error info: \(error)")
                callback("Error")
            }
        })
    }
    
    //reads the json produced by the call to the spotify url
    func parseSpotifyData(JSONData : Data, completion: @escaping (String) -> Void) {
        do {
            //reads the JSON
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
            print(readableJSON)

            //parses the JSON for tracks
            if let items = readableJSON["items"] as? [JSONStandard] {
                for i in 0..<items.count {
                    //gets the song information
                    let item = items[i]
                    let name = item["name"] as! String
                    let id = item["id"] as! String
                    let previewUrl = item["preview_url"] as? String
                    songs.append(ItemData(type: ItemType.SONG, name: name, artist: self.albumData.artist, image: self.albumData.image, spotify_id: id, previewUrl: previewUrl))
                    //calls back when all songs have been appended
                    if (items.count == songs.count) {
                        completion("Success")
                    }
                }
            }
        } catch {
            print("Error info: \(error)")
            let alert = createAlert(
                title: "Spotify Query Error",
                message: "\(error)",
                actionTitle: "Try again")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // goes back to previous view controller when the back button is clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        let searchView = self.storyboard!.instantiateViewController(withIdentifier: "searchScreenID")
        self.present(searchView, animated:false, completion: nil)
    }
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "songViewID") as? SongView
        
        // sets local variables in the new view controller
        nextVC!.songData = songs[indexPath.row]
        nextVC!.albumData = self.albumData
        
        // presents the new view controller
        self.present(nextVC!, animated:true, completion: nil)
    }
    
    // when the add button is clicked, create an item alert for this album
    @IBAction func addButtonClicked(_ sender: Any) {
        UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            .addItemAlert(name: self.albumData.name, type: ItemType.ALBUM, item: self.albumData, sender: self)
    }
}

// extension of search screen main allows for updating of the table view
extension AlbumView: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
        //sets the label
        let mainLabel = cell?.viewWithTag(3) as! UILabel
        mainLabel.text = songs[indexPath.row].name
        return cell!
    }
    
}
