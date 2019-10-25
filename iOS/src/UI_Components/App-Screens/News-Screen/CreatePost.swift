//
//  CreatePost.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/24/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// View Controller for creating a new post
class CreatePost: UIViewController, UITextViewDelegate {
    @IBOutlet weak var content_outlet: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.content_outlet.layer.borderWidth = 1
        self.content_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        self.content_outlet.delegate = self
    }
    
    // closes text view on return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // when the cancle button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when the done button is clicked, attempt to create post
    @IBAction func doneClicked(_ sender: Any) {
        if let content = content_outlet.text {
            if content.count < 1 || content.count > 250 {
                let alert = createAlert(
                    title: "Request Failed",
                    message: "Only allowed between 1 and 250 characters. Provided " + String(content.count),
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
            } else {
                let header: HTTPHeaders = [
                    "content": content,
                ]
                
                self.showSpinner(onView: self.view)
                self.macRequest(urlName: "post", httpMethod: .post, header: header, successAlert: false, callback: { jsonData -> Void in
                    self.removeSpinner()
                    if let statusCode = jsonData?["statusCode"] as? String {
                        if statusCode == "200" {
                            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NewsScreenMain")
                            self.present(nextVC, animated:true, completion: nil)
                        }
                    }
                })
            }
        }
    }
}

