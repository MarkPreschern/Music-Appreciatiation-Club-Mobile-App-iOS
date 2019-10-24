//
//  AddUser.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/24/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

// when the log out button is clicked, the user will be promted with an alert to logout
class AddUser: UIViewController, PopupScreen {
    
    var nameText = UITextField()
    var nuidText = UITextField()
    var pickAccess = UIPickerView()
    var pickRole = UIPickerView()
    var doneButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        self.view = UIView()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showPopup(callback: { response -> Void in
            if response == "Done" {
                self.removePopup()
            }
        })
    }
    
    func showPopup(callback: @escaping (String) -> Void) {
    }
    
    func removePopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

