//
//  SearchScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire
import JASON

// Represents information in a cell of the table view
struct ItemData {
    let type : ItemType! // the type of item
    let name : String! // the name of the item
    let artist : String! // the name of the artist of this item
    let image : UIImage! // the main image of the item
    let imageUrl : String! // the item's image url
    let spotify_id : String! // the item's uri
    let previewUrl : String! // the item's preview url
}

// Represents the type of item this is, either a song, album, or artist
enum ItemType {
    case SONG
    case ALBUM
    
    var toString : String {
        switch self {
        case .SONG: return "Song"
        case .ALBUM: return "Album"
        }
    }
}

typealias JSONStandard = [String : AnyObject] //typealias for json data

var currentQuery : String? // the current spotify query

var spotifySearchItems = [ItemData]() // list of items in the table view

// Represents the search screen. Holds information regarding:
// - Songs and albums available on spotify
// - ability to choose songs and albums weekly
class SearchScreenMain: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    
    @IBOutlet weak var view_outlet: UIView! // main view
    @IBOutlet weak var searchTextBox_outlet: SearchTextBox! //search text box
    @IBOutlet weak var tableView: UITableView! // table view
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.view_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        
        //sets search text box constraints
        self.searchTextBox_outlet.delegate = self
        self.searchTextBox_outlet.placeholder = "Albums and Songs"
        self.searchTextBox_outlet.autocorrectionType = UITextAutocorrectionType.no
        
        //sets table view constraints
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //loads the currentURL, or the defaultURL if the currentURL is nil
        if (spotifySearchItems.count == 0) {
            self.callSpotifySongAndAlbum(query: currentQuery == nil ? "Music" : currentQuery!)
        }
    }
    
    // Dismisses text field on 'return' key, and performs query if text isn't empty
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true) //ends editing of text field
        if (!textField.text!.isEmpty) {
            spotifySearchItems = [ItemData]() //resets table to empty
            currentQuery = textField.text
            // re-presents this view controller to dismiss any data that may still be loading in
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "searchScreenID")
            self.present(nextVC, animated:false, completion: nil)
        }
        return false
    }
    
    //calls to spotify api for songs and albums of this query and updates table
    func callSpotifySongAndAlbum(query : String!) {
        currentQuery = query //updates the current query
        
        // builds url's
        let albumURL = self.buildAlbumURL(query: query)
        let songURL = self.buildSongURL(query: query)
        
        spotifySearchItems = [ItemData]() //resets table to empty

        // calls the spotify url's, waiting for callback of success before moving to next steps
        self.callSpotifyURL(url: albumURL!, type: ItemType.ALBUM, callback: { (callback) -> Void in
            if (callback == "Success") {
                self.callSpotifyURL(url: songURL!, type: ItemType.SONG, callback: { (token) -> Void in
                })
            }
        })
    }
    
    //builds the song url given the query
    func buildSongURL(query : String!) -> String! {
        return "https://api.spotify.com/v1/search?q="
            + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            + "&type=track&market=US&limit=10";
    }
    
    //builds the album url given the query
    func buildAlbumURL(query : String!) -> String! {
        return "https://api.spotify.com/v1/search?q="
            + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            + "&type=album&market=US&limit=3";
    }
    
    //calls the spotify url
    func callSpotifyURL(url : String, type : ItemType, callback: @escaping (String) -> Void) {
        //callback handler is needed to get the authorization since requestSpotifyAuthorizationToken is asyncronous
        self.requestSpotifyAuthorizationToken(callback: { (token) -> Void in
            if (token != "Error") {
                //header information for spotify url call
                let headers : HTTPHeaders = [
                    "Accept" : "application/json",
                    "Content-Type" : "application/json",
                    "Authorization" : token
                ]
                
                //creates a request for the url
                Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJASON(completionHandler: {
                    response in
                    // asyncronously parses the json data, waiting for a response to continue
                    DispatchQueue.global(qos: .userInteractive).async {
                        if let json = response.result.value {
                            self.parseSpotifyData(jsonData: json, type: type, completion: { (response) -> Void in
                                if (response == "Success") {
                                    callback("Success")
                                }
                            })
                        }
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
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                let access_token = readableJSON["access_token"] as! String
                let token_type = readableJSON["token_type"] as! String
                callback(token_type + " " + access_token)
            } catch {
                print("Error info: \(error)")
                let alert = createAlert(
                    title: "Spotify Authorization Error",
                    message: "\(error)",
                    actionTitle: "Try again")
                self.present(alert, animated: true, completion: nil)
                callback("Error")
            }
        })
    }
    
    //reads the json produced by the call to the spotify url
    func parseSpotifyData(jsonData : JSON, type : ItemType, completion: @escaping (String) -> Void) {
        do {
            switch (type) {
            case .ALBUM:
                //parses the JSON for albums
                if let albums = jsonData["albums"].dictionary {
                    if let jsonItems = albums["items"] as? [JSONStandard] {
                        for i in 0..<jsonItems.count {
                            let item = jsonItems[i]
                            let name = item["name"] as! String
                            let id = item["id"] as! String
                            let artists = item["artists"] as! [JSONStandard]
                            var artistName = ""
                            for i in 0..<artists.count {
                                artistName.append(artists[i]["name"] as! String)
                                if (i != artists.count - 1) {
                                    artistName.append(", ")
                                }
                            }
                            if let images = item["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                let mainImageURL = imageData["url"] as! String
                                let mainImageData = NSData(contentsOf: URL(string: mainImageURL)!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                //updates table information
                                spotifySearchItems.append(ItemData.init(type: ItemType.ALBUM, name: name, artist: artistName, image: mainImage, imageUrl: mainImageURL, spotify_id: id, previewUrl: nil))
                                DispatchQueue.main.sync {
                                    self.tableView.reloadData()
                                }
                                if (i + 1 == jsonItems.count) {
                                    completion("Success")
                                }
                            }
                        }
                    }
                }
            case .SONG:
                //parses the JSON for tracks
                if let tracks = jsonData["tracks"].dictionary {
                    if let jsonItems = tracks["items"] as? [JSONStandard] {
                        for i in 0..<jsonItems.count {
                            let item = jsonItems[i]
                            let name = item["name"] as! String
                            let artists = item["artists"] as! [JSONStandard]
                            var artistName = ""
                            for i in 0..<artists.count {
                                artistName.append(artists[i]["name"] as! String)
                                if (i != artists.count - 1) {
                                    artistName.append(", ")
                                }
                            }
                            let id = item["id"] as! String
                            let previewUrl = item["preview_url"] as? String
                            if let album = item["album"] as? JSONStandard {
                                if let images = album["images"] as? [JSONStandard] {
                                    let imageData = images[0]
                                    let mainImageURL = imageData["url"] as! String
                                    let mainImageData = NSData(contentsOf: URL(string: mainImageURL)!)
                                    let mainImage = UIImage(data: mainImageData! as Data)
                                    
                                    //updates table information
                                    spotifySearchItems.append(ItemData.init(type: ItemType.SONG, name: name, artist: artistName, image: mainImage, imageUrl: mainImageURL, spotify_id: id, previewUrl: previewUrl))
                                    DispatchQueue.main.sync {
                                        self.tableView.reloadData()
                                    }
                                    if (i + 1 == jsonItems.count) {
                                        completion("Success")
                                    }
                                }
                            }
                        }
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
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // chooses view controller based on cell type
        switch (spotifySearchItems[indexPath.row].type!) {
        case .SONG:
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "songViewID") as? SongView
            nextVC!.songData = spotifySearchItems[indexPath.row]
            nextVC!.previousRestorationIdentifier = "searchScreenID"
            self.present(nextVC!, animated:true, completion: nil)
        case .ALBUM:
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? AlbumView
            nextVC!.albumData = spotifySearchItems[indexPath.row]
            nextVC!.previousRestorationIdentifier = "searchScreenID"
            songs = [ItemData]()
            self.present(nextVC!, animated:true, completion: nil)

        }
    }
}

// extension of search screen main allows for updating of the table view
extension SearchScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotifySearchItems.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = spotifySearchItems[indexPath.row].name
        //sets the image
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = spotifySearchItems[indexPath.row].image
        return cell!
    }
    
}
