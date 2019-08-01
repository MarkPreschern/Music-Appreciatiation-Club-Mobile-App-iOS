//
//  SearchScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Represents information in a cell of the table view
struct ItemData {
    let name : String!
    let mainImage : UIImage!
}

// Represents the search screen. Holds information regarding:
// - Songs and albums available on spotify
// - ability to choose songs and albums weekly
class SearchScreenMain: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var view_outlet: UIView! // main view
    @IBOutlet weak var searchTextBox_outlet: SearchTextBox! //search text box
    @IBOutlet weak var tableView: UITableView! // table view
    
    var items = [ItemData]() // list of items in the table view
    typealias JSONStandard = [String : AnyObject] //typealias for json data
    
    // default url for when the view first loads in
    let defaultURL = "https://api.spotify.com/v1/search?q=music&type=album%2Cartist%2Cplaylist%2Ctrack&limit=20"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        self.searchTextBox_outlet.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.dataSource = self
        
        self.callSpotifyURL(url: self.defaultURL)
    }
    
    // Dismisses text field on 'return' key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //builds the url given the query
    func buildURL(query : String!) -> String! {
        return "https://api.spotify.com/v1/search?q="
            + query
            + "&type=album%2Cartist%2Cplaylist%2Ctrack&limit=20";
    }

    //calls the spotify url
    func callSpotifyURL(url : String) {
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
                    self.parseSpotifyData(JSONData: response.data!)
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
    func parseSpotifyData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            print(readableJSON)
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count {
                        let item = items[i]
                        let name = item["name"] as! String
                        if let album = item["album"] as? JSONStandard {
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                self.items.append(ItemData.init(name: name, mainImage: mainImage))
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }
}

// extension of search screen main allows for updating of the table view
extension SearchScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.items[indexPath.row].name
        //sets the image
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = self.items[indexPath.row].mainImage
        return cell!
    }
}
