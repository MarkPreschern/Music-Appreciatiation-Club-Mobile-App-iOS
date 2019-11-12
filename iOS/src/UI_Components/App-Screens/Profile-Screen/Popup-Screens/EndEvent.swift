//
//  EndEvent.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/30/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

// the user is promted with an alert to logout
class EndEvent: UIViewController, PopupScreen {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showPopup()
    }

    // displays the popup alert
    func showPopup() {
        let alert = UIAlertController(title: "End Event", message: "Are you sure you want to end the current event? This action cannot be undone.", preferredStyle: UIAlertController.Style.alert)
        // handles if the user clicks "no"
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        // handles if the user clicks "yes"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.showSpinner(onView: self.view)
            self.macRequest(urlName: "endEvent", httpMethod: .post, header: nil, successAlert: false, attempt: 0, callback: { jsonData -> Void in
                if let statusCode = jsonData?["statusCode"] as? String {
                    if statusCode == "200" {
                        let alert = UIAlertController(
                        title: "Success",
                        message: jsonData?["message"] as? String,
                        preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(
                        title: "Close",
                        style: UIAlertAction.Style.default,
                        handler: { (alert: UIAlertAction!) in
                            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsScreenID")
                            self.present(nextVC, animated: false, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.removeSpinner()
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.removeSpinner()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }))
        // presents the alert
        self.present(alert, animated: true, completion: nil)
    }
}
