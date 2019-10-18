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
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var nameLabel_outlet: UILabel!
    @IBOutlet weak var roleLabel_outlet: UILabel!
    @IBOutlet weak var userImage_outlet: UIImageView!
    @IBOutlet weak var settings_outlet: UIImageView!
    @IBOutlet weak var members_outlet: UIImageView!
    @IBOutlet weak var logOut_outlet: UIButton!
    @IBOutlet weak var userDataView_outlet: UIView!
    
    @IBOutlet weak var table_outlet: UITableView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets task bar border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        // sets user data view border
        self.userDataView_outlet.layer.borderWidth = 1
        self.userDataView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        // sets name and role labels
        self.nameLabel_outlet.text = userData!.user_name!
        self.roleLabel_outlet.text = userData!.role_name! + ": " + userData!.role_description!
        
        // sets the user image
        if userData.image_data == nil {
            self.userImage_outlet.image = UIImage(named: "default-profile-image")
        } else {
            self.userImage_outlet.image = userData.image_data
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
        
        // sets log out button border
        self.logOut_outlet.layer.borderWidth = 1
        self.logOut_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        self.retrievePopularPicks()
    }
    
    // retrieves the popular picks of this user for the MAC API
    func retrievePopularPicks() {
        self.showSpinner(onView: self.view)
        self.macRequest(urlName: "userPopularPicks", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["popular_picks"] as? [JSONStandard] {
                        if items.count == 0 {
                            self.removeSpinner()
                        }
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
                            if i == items.count - 1 {
                                self.table_outlet.reloadData()
                                self.removeSpinner()
                            }
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate items",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                        self.removeSpinner()
                    }
                } else {
                    self.removeSpinner()
                }
            } else {
                self.removeSpinner()
            }
        })
    }
    
    // handles when a user clicks the user image, prompting the user to select a new image
    @objc func imageClicked(gesture: UITapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            let imageManager = ImagePickerManager.init()
            imageManager.pickImage(self, { image -> Void in
                self.showSpinner(onView: self.view)
                self.postImage(image: image, callback: { response -> Void in
                    if response == "Success" {
                        self.userImage_outlet.image = image
                        self.removeSpinner()
                    } else if response == "Failure" {
                        self.removeSpinner()
                    }
                })
            })
        }
    }
    
    // posts the image using the MAC API
    func postImage(image: UIImage, callback: @escaping (String) -> Void) {
        let url = API_URL + "image"
        let headers = [
            "user_id" : "\(String(describing: userData.user_id!))",
            "authorization_token" : userData?.authorization_token ?? "",
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = image.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(imageData, withName: "image_data",fileName: "image_data.jpg", mimeType: "image_data/jpg")
                print(imageData)
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let readableJSON = response.result.value as? JSONStandard {
                        if let statusCode = readableJSON["statusCode"] as? String {
                            if (statusCode == "200") {
                                callback("Success")
                            } else {
                                print(readableJSON)
                                let alert = createAlert(title: readableJSON["title"] as? String, message: readableJSON["description"] as? String, actionTitle: "close")
                                self.present(alert, animated: true, completion: nil)
                                callback("Failure")
                            }
                        } else {
                            print(readableJSON)
                            let alert = createAlert(
                                title: "Request Failed",
                                message: "Error occured during request",
                                actionTitle: "Try Again")
                            self.present(alert, animated: true, completion: nil)
                            callback("Failure")
                        }
                    } else {
                        print(response)
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                        callback("Failure")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                let alert = createAlert(
                    title: "Request Failed",
                    message: "Error occured during request",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                callback("Failure")
            }
        }
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

    
    // when the log out button is clicked, the user will be promted with an alert to logout
    @IBAction func logOutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        // handles if the user clicks "no"
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        // handles if the user clicks "yes"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            // resets global variables
            self.resetGlobalVariables()
            
            // presents the start screen
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "StartScreenID")
            self.present(nextVC, animated:true, completion: nil)
        }))
        // presents the alert
        self.present(alert, animated: true, completion: nil)
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

