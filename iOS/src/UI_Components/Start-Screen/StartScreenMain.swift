//
//  StartScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/4/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Represents user data
struct UserData {
    let user_id : Int? // user's id
    let user_name : String? // user's name
    let user_nuid : String? // user's nuid
    let authorization_token: String? // user's authorization token
    let role_id: Int? // user's role id
    let access_id: Int? //user access id
}

// represents this user
var userData : UserData?

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
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if (sender.restorationIdentifier == "LoginToNewsButton") {
            self.requestAuthorization(callback: { response -> Void in
                if (response) {
                    let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NewsScreenMain")
                    self.present(nextVC, animated:true, completion: nil)
                }
            })
        } else {
            let alert = createAlert(
                title: "Login Failed",
                message: "Invalid Button Click",
                actionTitle: "Try Again")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    // requests authorization from the user
    func requestAuthorization(callback: @escaping (Bool) -> Void) {
        //header information for spotify url call
        let url = "https://50pnu03u26.execute-api.us-east-2.amazonaws.com/MacTesting/api.mac.com/authorization"
        let headers : HTTPHeaders = [
            "name" : self.name_outlet.text ?? "",
            "nuid" : self.nuid_outlet.text ?? ""
        ]
        
        //creates a request for the authorization token
        Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: {
            response in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                let statusCode = readableJSON["statusCode"] as! String
                // reads user data if the request was successful
                if (statusCode == "200") {
                    let user = readableJSON["user"] as! JSONStandard
                    userData = UserData(
                        user_id: user["user_id"] as? Int,
                        user_name: user["name"] as? String,
                        user_nuid: user["nuid"] as? String,
                        authorization_token: user["authorization"] as? String,
                        role_id: user["role_id"] as? Int,
                        access_id: user["access_id"] as? Int)
                    if (self.isChecked) {
                        //TODO: add user information and isChecked var to SQLite if credentials are correct
                    }
                    callback(true)
                } else {
                    let alert = createAlert(
                        title: "Login Failed",
                        message: "Invalid login information",
                        actionTitle: "Try Again")
                    self.present(alert, animated: true, completion: nil)
                    callback(false)
                }
            } catch {
                print("Error info: \(error)")
                let alert = createAlert(
                    title: "Login Failed",
                    message: "Error occured during login",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                callback(false)
            }
        })
    }
}
