//
//  StartScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/4/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

var name : String?
var nuid : String?

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
            let alert = UIAlertController(
                title: "Login Failed",
                message: "Invalid login information.",
                preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(
                title: "Try Again.",
                style: UIAlertAction.Style.default,
                handler: nil))
            
            if (name_outlet == nil || nuid_outlet.text == nil /* || query to nuid database is incorrect */) {
                self.present(alert, animated: true, completion: nil)
                return false;
            } else {
                // add user information and isChecked var to database if credentials are correct
                print((self.name_outlet.text ?? "") + " " + (self.nuid_outlet.text ?? ""))
                name = name_outlet.text!
                nuid = nuid_outlet.text!
                
                //switches to 'news' view controller
                if (identifier == "LoginToNewsSeque") {
                    return true;
                }
            }
            return false;
        } catch {
            print("Error info: \(error)")
            let alert = UIAlertController(
                title: "Login Failed",
                message: "Exception occured during login process",
                preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(
                title: "Try Again. Contact MAC if the problem persists.",
                style: UIAlertAction.Style.default,
                handler: nil))
        }
    }
}
