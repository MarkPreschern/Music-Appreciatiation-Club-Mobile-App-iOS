//
//  AlterEvent.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 11/4/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// allows the user to schedule the current event to a different date
class AlterEvent: UIViewController, PopupScreen, UITextFieldDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var name_outlet: UITextField!
    @IBOutlet weak var description_outlet: UITextField!
    @IBOutlet weak var date_picker: UIPickerView!
    
    // dates of which the user can choose for an end date
    var dates = [Date]()
    // the current event ID
    var eventID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name_outlet.delegate = self
        self.description_outlet.delegate = self
        self.date_picker.delegate = self
        self.date_picker.dataSource = self
        
        self.retrieveEventData()
    }
    
    // loads in event data from the MAC API, and populates self.dates accordingly
    func retrieveEventData() {
        self.showSpinner(onView: self.view, clickable: false)
        self.macRequest(urlName: "event", httpMethod: .get, header: nil, successAlert: false, attempt: 0, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    // sets event data
                    let event = jsonData?["event"]
                    self.eventID = event?["event_id"] as! Int
                    self.name_outlet.text = event?["name"] as? String
                    self.description_outlet.text = event?["description"] as? String
                    
                    // sets dates based on end_date
                    // Optional("2019-11-10T12:00:00.000Z")
                    let endDateString = (event?["end_date"] as! String).components(separatedBy: "T")[0]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let startDate = Date()
                    self.dates.append(startDate)
                    let endDate = dateFormatter.date(from: endDateString)
                    var endDateIndex = 0;
                    // allows an event to end a maximum of 60 days from today
                    for n in 1...59 {
                        let nextDate = Calendar.current.date(byAdding: .day, value: n, to: startDate)!
                        self.dates.append(nextDate)
                        if Calendar.current.compare(endDate!, to: nextDate, toGranularity: .day) == .orderedSame {
                            endDateIndex = n
                        }
                        if n == 59 {
                            self.date_picker.reloadAllComponents()
                            self.date_picker.selectRow(endDateIndex, inComponent: 0, animated: false)
                            self.removeSpinner()
                        }
                    }
                } else {
                    self.removeSpinner()
                }
            } else {
                self.removeSpinner()
            }
        })
    }
    
    // closes the text field on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // when the cancel button is clicked, close popup
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        if name_outlet.text == nil || name_outlet.text == "" {
            let alert = createAlert(
                title: "Name Not Specified",
                message: "Please specify the event's name",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else if description_outlet.text == nil || description_outlet.text == "" {
            let alert = createAlert(
                title: "Description Not Specified",
                message: "Please specify the event's description",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let header: HTTPHeaders = [
                "name": name_outlet.text!,
                "description": description_outlet.text!,
                "end_date": dateFormatter.string(from: self.dates[self.date_picker.selectedRow(inComponent: 0)]) + " 23:00:00",
                "event_id": String(self.eventID)
            ]
            
            self.showSpinner(onView: self.view, clickable: false)
            self.macRequest(urlName: "event", httpMethod: .post, header: header, successAlert: false, attempt: 0, callback: { jsonData -> Void in
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
extension AlterEvent: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dates.count
    }
    
    // sets the pick title
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = UIFont (name: "Helvetica Neue", size: 12)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL dd, yyyy"
        label.text = dateFormatter.string(from: self.dates[row])
        label.textAlignment = .center
        return label
    }
}
