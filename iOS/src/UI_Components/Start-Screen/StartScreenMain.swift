//
//  StartScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/4/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

var user_name : String? // user's name
var user_nuid : String? // user's nuid

//returns an alert with the given title, message, and action title
func createAlert(title: String!, message: String!, actionTitle: String!) -> UIAlertController {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(
        title: actionTitle,
        style: UIAlertAction.Style.default,
        handler: nil))
    
    return alert
}

// Represents the main login page
class StartScreenMain: UIViewController, UITextFieldDelegate {
    
    var isChecked = false //if the check box 'Remember Me' is checked
    @IBOutlet weak var name_outlet: UITextField!
    @IBOutlet weak var nuid_outlet: UITextField!
    
    @IBOutlet weak var checkbox_outlet: UIButton!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name_outlet.delegate = self
        self.nuid_outlet.delegate = self
        
        self.checkbox_outlet.layer.borderWidth = 1.0
        self.checkbox_outlet.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    // Dismisses text field on 'return' key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Updates check box when tapped and global variable 'isChecked'
    @IBAction func CheckBoxTapped(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            self.isChecked = false
        } else {
            sender.isSelected = true
            self.isChecked = true
        }
    }
    
    
    // Performs login with name and nuid. Effect:
    // - if invalid login credentials, the user is prompted with an alert
    // - if correct login information, their user information is added to the database if not already contained
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        do {
            if (false /* query to nuid database is incorrect */) {
                let alert = createAlert(
                    title: "Login Failed",
                    message: "Invalid login information",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                return false;
            } else {
                if (self.isChecked) {
                    //TODO: add user information and isChecked var to SQLite if credentials are correct
                }
            
                //updates global variables
                user_name = name_outlet.text!
                user_nuid = nuid_outlet.text!
                
                //switches to 'news' view controller
                if (identifier == "LoginToNewsSeque") {
                    return true;
                }
            }
            return false;
        }
    }
}
