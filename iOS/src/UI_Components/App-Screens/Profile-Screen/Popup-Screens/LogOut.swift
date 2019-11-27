//
//  LogOut.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/21/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

// the user is promted with an alert to logout
class LogOut: UIViewController, PopupScreen {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showPopup()
    }

    // displays the popup alert
    func showPopup() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        // handles if the user clicks "no"
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        // handles if the user clicks "yes"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            // resets global variables
            self.resetGlobalVariables()
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartScreenID")
            self.present(nextVC, animated: true, completion: nil)
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
        vSpinner = UIView()
        vSpinnerControllerRestorationIdentifier = nil
        settings = [Setting]()
    }

}
