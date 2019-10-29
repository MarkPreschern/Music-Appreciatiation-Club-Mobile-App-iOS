//
//  AddRole.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/29/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Responsible for allowing the user to create a new role
class AddRole: UIViewController, PopupScreen, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var name_outlet: UITextField!
    @IBOutlet weak var content_outlet: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.content_outlet.layer.borderWidth = 1
        self.content_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        self.content_outlet.textColor = UIColor.lightGray
        
        self.content_outlet.delegate = self
        self.name_outlet.delegate = self
    }
    
    // closes the text field on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // removes placeholder when user begins editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // closes text view on return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.isEmpty {
                textView.text = "Description"
                textView.textColor = UIColor.lightGray
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // when the cancel button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when the done button is clicked, attempt to add the role
    @IBAction func doneClicked(_ sender: Any) {
        if name_outlet.text == nil || name_outlet.text == "" {
            let alert = createAlert(
                title: "Name Not Specified",
                message: "Please specify the role's name",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else if content_outlet.text == nil || content_outlet.text == "" {
            let alert = createAlert(
                title: "Description Not Specified",
                message: "Please specify the role's description",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else {
            let header: HTTPHeaders = [
                "role_name": name_outlet.text!,
                "role_description": content_outlet.text!,
            ]
            
            self.showSpinner(onView: self.view)
            self.macRequest(urlName: "role", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
                self.removeSpinner()
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
                    }
                }
            })
        }
    }
}
