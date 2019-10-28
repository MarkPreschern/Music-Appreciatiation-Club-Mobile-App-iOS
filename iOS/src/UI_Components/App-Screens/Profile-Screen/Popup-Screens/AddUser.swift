//
//  AddUser.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/24/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Represents a role or access name and id
struct PickerData {
    let name : String!
    let id : Int!
}

// add a custom user to the app
class AddUser: UIViewController, PopupScreen, UITextFieldDelegate, UIPickerViewDelegate {
    
    var roleData = [PickerData]()
    var accessData = [PickerData]()
    
    @IBOutlet weak var name_outlet: UITextField!
    @IBOutlet weak var nuid_outlet: UITextField!
    @IBOutlet weak var role_picker: UIPickerView!
    @IBOutlet weak var access_picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name_outlet.delegate = self
        self.nuid_outlet.delegate = self
        self.role_picker.delegate = self
        self.access_picker.delegate = self
        self.role_picker.dataSource = self
        self.access_picker.dataSource = self
        
        self.loadPickerData()
    }
    
    // determines what role's and access' the user can pick from and reloads the picker data
    func loadPickerData() {
        // loads in role data
        self.macRequest(urlName: "roles", httpMethod: .get, header: nil, successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["roles"] as? [JSONStandard] {
                        for i in 0..<items.count {
                            let item = items[i]
                            
                            let role = PickerData(
                                name: item["name"] as? String,
                                id: item["role_id"] as? Int)
                            
                            // appends the role depending on the user's access
                            if userData.access_name == "Admin" || userData.access_name == "Developer" || (userData.access_name == "Moderator" && role.name == "Member") {
                                self.roleData.append(role)
                            }
                            
                            if i == items.count - 1 {
                                self.role_picker.reloadAllComponents()
                            }
                        }
                    } else {
                        let alert = createAlert(
                            title: "Request Failed",
                            message: "Error occured during request, couldn't locate items",
                            actionTitle: "Close")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
        
        // loads in access data
        if userData.access_name == "Moderator" {
            self.accessData.append(PickerData(name: "User", id: 4))
            self.access_picker.reloadAllComponents()
        } else if userData.access_name == "Admin" {
            self.accessData.append(PickerData(name: "User", id: 4))
            self.accessData.append(PickerData(name: "Moderator", id: 3))
            self.access_picker.reloadAllComponents()
        } else if userData.access_name == "Developer" {
            self.accessData.append(PickerData(name: "User", id: 4))
            self.accessData.append(PickerData(name: "Moderator", id: 3))
            self.accessData.append(PickerData(name: "Admin", id: 2))
            self.accessData.append(PickerData(name: "Developer", id: 1))
            self.access_picker.reloadAllComponents()
        }
    }

    // closes the text field on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // when the cancel button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when the done button is clicked, attempts to add the user
    @IBAction func doneClicked(_ sender: Any) {
        if name_outlet.text == nil || name_outlet.text == "" {
            let alert = createAlert(
                title: "Name Not Specified",
                message: "Please specify the user's name",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else if nuid_outlet.text == nil || nuid_outlet.text == "" {
            let alert = createAlert(
                title: "NUID Not Specified",
                message: "Please specify the user's NUID",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else {
            let header: HTTPHeaders = [
                "user_name": name_outlet.text!,
                "user_nuid": nuid_outlet.text!,
                "access_id": String(self.accessData[self.access_picker.selectedRow(inComponent: 0)].id),
                "role_id": String(self.roleData[self.role_picker.selectedRow(inComponent: 0)].id)
            ]
            
            self.showSpinner(onView: self.view)
            self.macRequest(urlName: "user", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
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

// extension handles picker data
extension AddUser: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.restorationIdentifier == "rolePicker") {
            return self.roleData.count
        } else if (pickerView.restorationIdentifier == "accessPicker") {
            return self.accessData.count
        }
        return -1
    }
    
    // sets the pick title
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if (pickerView.restorationIdentifier == "rolePicker") {
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            label.font = UIFont (name: "Helvetica Neue", size: 10)
            label.text = self.roleData[row].name
            label.textAlignment = .center
            return label
        } else if (pickerView.restorationIdentifier == "accessPicker") {
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            label.font = UIFont(name: "Helvetica Neue", size: 10)
            label.text = self.accessData[row].name
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            return label
        } else {
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            return label;
        }
    }
}

