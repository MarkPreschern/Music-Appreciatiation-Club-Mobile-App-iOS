//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

// Represents the profile screen. Holds information regarding:
// - User information (name, nuid)
// - User's popular top picks (songs & albums)
class ProfileScreenMain: UIViewController, UITableViewDelegate {
    
    // popular user picks
    var popularPicks = [Pick]()
    
    // if the profile screen is of the current user
    var currentUser = true
    
    // the user details of this user's profile
    var userDetails: UserData? = nil
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var nameLabel_outlet: UILabel!
    @IBOutlet weak var roleLabel_outlet: UILabel!
    @IBOutlet weak var userImage_outlet: UIImageView!
    @IBOutlet weak var settings_outlet: UIImageView!
    @IBOutlet weak var members_outlet: UIImageView!
    @IBOutlet weak var userDataView_outlet: UIView!
    
    @IBOutlet weak var table_outlet: UITableView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets user details to this user's data if nil
        self.userDetails = (self.userDetails == nil ? userData : self.userDetails)
        
        // sets task bar border
        self.view_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        
        // sets user data view border
        self.userDataView_outlet.layer.borderWidth = 1
        self.userDataView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        // sets name and role labels
        self.nameLabel_outlet.text = self.userDetails!.user_name!
        self.roleLabel_outlet.text = self.userDetails!.role_name! + ": " + userDetails!.role_description!
        
        // sets the user image
        if self.userDetails!.image_data == nil {
            self.userImage_outlet.image = UIImage(named: "default-profile-image")
        } else {
            self.userImage_outlet.image = self.userDetails!.image_data
        }
        
        // creates a user image gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileScreenMain.imageClicked(gesture:)))
        self.userImage_outlet.addGestureRecognizer(tapGesture)
        // creates a settings image gesture recognizer
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(ProfileScreenMain.settingsClicked(gesture:)))
        self.settings_outlet.addGestureRecognizer(tapGesture2)
        // creates a members image gesture recognizer
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(ProfileScreenMain.membersClicked(gesture:)))
        self.members_outlet.addGestureRecognizer(tapGesture3)
        
        //sets table outlet's datasource to this class's extension
        self.table_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.table_outlet.dataSource = self
        self.table_outlet.delegate = self
        
        self.retrievePopularPicks()
    }
    
    // retrieves the popular picks of this user for the MAC API
    func retrievePopularPicks() {
        let header: HTTPHeaders = [
            "member_id": String(self.userDetails?.user_id ?? -1),
        ]
        
        self.macRequest(urlName: "userPopularPicks", httpMethod: .get, header: header, successAlert: false, attempt: 0, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["popular_picks"] as? [JSONStandard] {
                        for i in 0..<items.count {
                            let item = items[i]
                            let imageUrl = item["item_image_url"] as! String
                            let mainImageData = NSData(contentsOf: URL(string: imageUrl)!)
                            let mainImage = UIImage(data: mainImageData! as Data)
                            
                            let pick = Pick(
                                pickID: item["popular_id"] as? Int,
                                itemData: ItemData(
                                    type: (item["is_album"] as? Int) == 1 ? ItemType.ALBUM : ItemType.SONG,
                                    name: item["item_name"] as? String,
                                    artist: item["item_artist"] as? String,
                                    image: mainImage,
                                    imageUrl: imageUrl,
                                    spotify_id: item["item_id"] as? String,
                                    previewUrl: item["item_preview_url"] as? String),
                                voteData: VoteData(
                                    totalVotes: item["votes"] as? Int,
                                    upVoteData: nil,
                                    downVoteData: nil,
                                    userVoteID: nil),
                                userData: nil)
                            self.popularPicks.append(pick)
                            self.table_outlet.reloadData()
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate items",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    // handles when a user clicks the user image, prompting the user to select a new image
    @objc func imageClicked(gesture: UITapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil && (self.currentUser || userData.access_name == "Developer") {
            let imageManager = ImagePickerManager.init()
            imageManager.pickImage(self, { image -> Void in
                self.postImage(image: image, callback: { response -> Void in
                    if response == "Success" {
                        self.userImage_outlet.image = image
                        self.userDetails?.image_data = image
                        userData.image_data = image
                    }
                })
            })
        }
    }
    
    // posts the image using the MAC API
    func postImage(image: UIImage, callback: @escaping (String) -> Void) {
        let url = API_URL + "image"
        let headers = [
            "user_id" : "\(String(describing: userData.user_id!).sanitize())",
            "authorization_token" : userData?.authorization_token?.sanitize() ?? "",
        ]
        
        let parameters = [
            "imageData": image.jpegData(compressionQuality: 0.2)!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                print(readableJSON)
                if let statusCode = readableJSON["statusCode"] as? String {
                    if (statusCode == "200") {
                        callback("Success")
                    } else {
                        let alert = createAlert(title: readableJSON["title"] as? String, message: readableJSON["description"] as? String, actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                        callback("Failure")
                    }
                } else {
                    let alert = createAlert(
                        title: "Request Failed",
                        message: "Error occured during request",
                        actionTitle: "Close")
                    self.present(alert, animated: true, completion: nil)
                    callback("Failure")
                }
            } catch {
                print("Error info: \(error)")
                let alert = createAlert(
                    title: "Request Failed",
                    message: "Error occured during request",
                    actionTitle: "Close")
                self.present(alert, animated: true, completion: nil)
                callback("Failure")
            }
        })
    }
    
    // handles when a user clicks the settings image, moving to the Settings View Controller
    @objc func settingsClicked(gesture: UITapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "settingsScreenID")
            self.present(nextVC, animated:true, completion: nil)
        }
    }
    
    // handles when a user clicks the members image, moving to the Members View Controller
    @objc func membersClicked(gesture: UITapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "membersScreenID")
            self.present(nextVC, animated:true, completion: nil)
        }
    }
    
    // resets all global variables to empty values and userDefaults values
    func resetGlobalVariables() {
        let nameData = NSKeyedArchiver.archivedData(withRootObject: "")
        let nuidData = NSKeyedArchiver.archivedData(withRootObject: "")
        UserDefaults.standard.set(nameData, forKey: "user_name")
        UserDefaults.standard.set(nuidData, forKey: "user_nuid")
        
        userData = nil
        currentQuery = String()
        spotifySearchItems = [ItemData]()
        songs = [ItemData]()
        player = AVAudioPlayer()
        session = AVAudioSession()
        vSpinner = UIView()
    }
    
    // go to the members View Controller when clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "membersScreenID")
        self.present(nextVC, animated:true, completion: nil)
    }
    
    // when table view cell is tapped, move to controller of cell type
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.popularPicks[indexPath.row].itemData.type == ItemType.SONG {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "songViewID") as? SongView
            nextVC!.songData = self.popularPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "profileScreenID"
            self.present(nextVC!, animated:true, completion: nil)
        } else if self.popularPicks[indexPath.row].itemData.type == ItemType.ALBUM {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? AlbumView
            nextVC!.albumData = self.popularPicks[indexPath.row].itemData
            nextVC!.previousRestorationIdentifier = "profileScreenID"
            self.present(nextVC!, animated:true, completion: nil)
        }
    }
}

// extension handles table data
extension ProfileScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.popularPicks.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularCell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.popularPicks[indexPath.row].itemData.name
        //sets the image
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = self.popularPicks[indexPath.row].itemData.image
        
        self.updateVoteLable(index: indexPath.row, cell: cell)
        
        return cell ?? UITableViewCell()
    }
    
    // updates the vote label at this index based on it's vote count
    func updateVoteLable(index: Int, cell: UITableViewCell?) {
        let votes = self.popularPicks[index].voteData.totalVotes ?? 0
        let voteLabel = cell?.viewWithTag(4) as! UILabel
        voteLabel.text = String(abs(votes))
        if votes > 0 {
            voteLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        } else if votes < 0 {
            voteLabel.textColor = UIColor.red
        } else {
            voteLabel.textColor = UIColor.gray
        }
    }
}
