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
class ProfileScreenMain: UIViewController {
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var nameLabel_outlet: UILabel!
    @IBOutlet weak var roleLabel_outlet: UILabel!
    @IBOutlet weak var userImage_outlet: UIImageView!
    @IBOutlet weak var settings_outlet: UIImageView!
    @IBOutlet weak var members_outlet: UIImageView!
    @IBOutlet weak var logOut_outlet: UIButton!
    @IBOutlet weak var userDataView_outlet: UIView!
    
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
        
        // sets log out button border
        self.logOut_outlet.layer.borderWidth = 1
        self.logOut_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
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
        let header: HTTPHeaders = [
            "image_data": image.pngData()!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        ]
        print(header)
        self.macRequest(urlName: "image", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if (statusCode == "200") {
                    callback("Success")
                } else {
                    let alert = createAlert(
                        title: jsonData?["title"] as? String,
                        message: jsonData?["description"] as? String,
                        actionTitle: "Try Again")
                    self.present(alert, animated: true, completion: nil)
                    callback("Failure")
                }
            } else {
                let alert = createAlert(
                    title: "Image Request Failed",
                    message: "Server-side error occured",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                callback("Failure")
            }
        })
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
}

