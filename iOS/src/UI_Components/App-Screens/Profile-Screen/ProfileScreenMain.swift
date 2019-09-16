//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

// Represents the profile screen. Holds information regarding:
// - User information (name, nuid)
// - User's top picks (songs & albums)
class ProfileScreenMain: UIViewController {
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var nameLabel_outlet: UILabel!
    @IBOutlet weak var logOut_outlet: UIButton!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets task bar border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        // sets name label border and to user name
        self.nameLabel_outlet.layer.borderWidth = 1
        self.nameLabel_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        self.nameLabel_outlet.text = userData?.user_name
        
        // sets log out button border
        self.logOut_outlet.layer.borderWidth = 1
        self.logOut_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
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
            
            // TODO: - Update SQLite user information
            
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

