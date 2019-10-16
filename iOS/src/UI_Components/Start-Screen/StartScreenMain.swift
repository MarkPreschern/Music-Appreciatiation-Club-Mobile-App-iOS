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
    // user specific data
    let user_id : Int? // user's id
    let user_name : String? // user's name
    let user_nuid : String? // user's nuid
    let authorization_token: String? // user's authorization token
    let role_id: Int? // user's role id
    let access_id: Int? //user access id
    
    // user role data
    var role_name: String?
    var role_description: String?
    
    // user access data
    var access_name: String?
    var access_description: String?
    
    // user image
    var image_data: UIImage?
}

// represents this user
var userData : UserData!

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
        
        // shows loading screen until a user is or isn't validated
        self.showSpinner(onView: self.view)
        self.validateExistingUser()
    }
    
    // validates that a user choose 'remember me' and logs them in if so
    func validateExistingUser() {
        let nameData = UserDefaults.standard.data(forKey: "user_name")
        let nuidData = UserDefaults.standard.data(forKey: "user_nuid")
        let user_name = NSKeyedUnarchiver.unarchiveObject(with: nameData ?? Data())
        let user_nuid = NSKeyedUnarchiver.unarchiveObject(with: nuidData ?? Data())
        
        self.requestAuthorization(loginRequest: false, name: user_name as? String, nuid: user_nuid as? String, callback: { response -> Void in
            if (response == "Success") {
                self.retrieveUserData(callback: { response2 -> Void in
                    if (response2 == "Success") {
                        self.removeSpinner()
                        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NewsScreenMain")
                        self.present(nextVC, animated:true, completion: nil)
                    } else if (response2 == "Failure") {
                        self.removeSpinner();
                    }
                })
            } else if (response == "Failure"){
                self.removeSpinner()
            }
        })
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
            self.showSpinner(onView: self.view)
            self.requestAuthorization(loginRequest: true, name: self.name_outlet.text ?? "", nuid: self.nuid_outlet.text ?? "", callback: { response -> Void in
                if (response == "Success") {
                    self.retrieveUserData(callback: { response2 -> Void in
                        if (response2 == "Success") {
                            self.removeSpinner()
                            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NewsScreenMain")
                            self.present(nextVC, animated:true, completion: nil)
                        } else if (response2 == "Failure") {
                            self.removeSpinner();
                        }
                    })
                } else if (response == "Failure") {
                    self.removeSpinner()
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
    func requestAuthorization(loginRequest: Bool, name: String?, nuid: String?, callback: @escaping (String) -> Void) {
        //header information for spotify url call
        let url = "https://50pnu03u26.execute-api.us-east-2.amazonaws.com/MacTesting/api.mac.com/authorization"
        let headers : HTTPHeaders = [
            "name" : name ?? "",
            "nuid" : nuid ?? ""
        ]
        
        //creates a request for the authorization token
        Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: {
            response in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                if let statusCode = readableJSON["statusCode"] as? String {
                    // reads user data if the request was successful
                    if (statusCode == "200") {
                        let user = readableJSON["user"] as! JSONStandard
                        userData = UserData(
                            user_id: user["user_id"] as? Int,
                            user_name: user["name"] as? String,
                            user_nuid: user["nuid"] as? String,
                            authorization_token: user["authorization"] as? String,
                            role_id: user["role_id"] as? Int,
                            access_id: user["access_id"] as? Int,
                            role_name: nil,
                            role_description: nil,
                            access_name: nil,
                            access_description: nil,
                            image_data: nil)
                        if (self.isChecked) {
                            let nameData = NSKeyedArchiver.archivedData(withRootObject: name ?? "")
                            let nuidData = NSKeyedArchiver.archivedData(withRootObject: nuid ?? "")
                            UserDefaults.standard.set(nameData, forKey: "user_name")
                            UserDefaults.standard.set(nuidData, forKey: "user_nuid")
                        }
                        callback("Success")
                    } else {
                        if loginRequest {
                            let alert = createAlert(
                                title: readableJSON["title"] as? String,
                                message: readableJSON["description"] as? String,
                                actionTitle: "Try Again")
                            self.present(alert, animated: true, completion: nil)
                        }
                        callback("Failure")
                    }
                } else {
                    if loginRequest {
                        let alert = createAlert(
                            title: "Login Failed",
                            message: "Server-side error occured",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                    }
                    callback("Failure")
                }
            } catch {
                do {
                    var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                    print("Error info: \(error)")
                    if loginRequest {
                        let alert = createAlert(
                            title: readableJSON["title"] as? String,
                            message: readableJSON["description"] as? String,
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                    }
                    callback("Failure")
                } catch {
                    print("Error info: \(error)")
                    if loginRequest {
                        let alert = createAlert(
                            title: "Login Failed",
                            message: "Error occured during request",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                    }
                    callback("Failure")
                }
                
            }
        })
    }
    
    // Gets the user's specific role and access data
    func retrieveUserData(callback: @escaping (String) -> Void) {
        self.retrieveRoleData(callback: { response1 -> Void in
            if response1 == "Success" {
                self.retrieveAccessData(callback: { response2 -> Void in
                    if response2 == "Success" {
                        self.retrieveImageData(callback: { response3 -> Void in
                            if response3 == "Success" || response3 == "Failure" {
                                callback(response3)
                            }
                        })
                    } else if response2 == "Failure" {
                        callback(response2)
                    }
                })
            } else if response1 == "Failure" {
                callback(response1)
            }
        })
    }
    
    // Gets the user's specific role data
    func retrieveRoleData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "role", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if (statusCode == "200") {
                    if let items = jsonData?["items"] as? [JSONStandard] {
                        if items.count == 0 {
                            let alert = createAlert(
                                title: "Role Request Failed",
                                message: "Missing Role Data",
                                actionTitle: "Contact club moderator")
                            self.present(alert, animated: true, completion: nil)
                            callback("Failure")
                        } else {
                            userData.role_name = items[0]["name"] as? String
                            userData.role_description = items[0]["description"] as? String
                            callback("Success")
                        }
                    } else {
                        let alert = createAlert(
                            title: "Role Request Failed",
                            message: "Server-side error occured",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                        callback("Failure")
                    }
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
                    title: "Role Request Failed",
                    message: "Server-side error occured",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                callback("Failure")
            }
        })
    }
    
    // Gets the user's specific access data
    func retrieveAccessData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "access", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if (statusCode == "200") {
                    if let items = jsonData?["items"] as? [JSONStandard] {
                        if items.count == 0 {
                            let alert = createAlert(
                                title: "Access Request Failed",
                                message: "Missing Access Data",
                                actionTitle: "Contact club moderator")
                            self.present(alert, animated: true, completion: nil)
                            callback("Failure")
                        } else {
                            userData.access_name = items[0]["name"] as? String
                            userData.access_description = items[0]["description"] as? String
                            callback("Success")
                        }
                    } else {
                        let alert = createAlert(
                            title: "Access Request Failed",
                            message: "Server-side error occured",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                        callback("Failure")
                    }
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
                    title: "Access Request Failed",
                    message: "Server-side error occured",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
                callback("Failure")
            }
        })
    }
    
    // Gets the user's specific image data
    func retrieveImageData(callback: @escaping (String) -> Void) {
        self.macRequest(urlName: "image", httpMethod: .get, header: [:], successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if (statusCode == "200") {
                    if let items = jsonData?["items"] as? [JSONStandard] {
                        if items.count == 0 {
                            userData.image_data = nil
                            callback("Success")
                        } else {
                            let imageData = items[0]["image_data"] as! String
                            let imagePNG = NSData(base64Encoded: imageData, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            userData.image_data = UIImage(data: imagePNG as Data)!
                            callback("Success")
                        }
                    } else {
                        let alert = createAlert(
                            title: "Image Request Failed",
                            message: "Server-side error occured",
                            actionTitle: "Try Again")
                        self.present(alert, animated: true, completion: nil)
                        callback("Failure")
                    }
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
}
