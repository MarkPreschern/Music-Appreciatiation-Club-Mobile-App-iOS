//
//  CreatePost.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/24/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// View Controller for creating a new post
class CreatePost: UIViewController, PopupScreen {
    @IBOutlet weak var title_outlet: UITextField!
    @IBOutlet weak var content_outlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showPopup(callback: { response -> Void in
            if response == "Done" {
                self.removePopup()
            }
        })
    }

    func showPopup(callback: @escaping (String) -> Void) {
        // TODO
    }
    
    func removePopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // when the cancle button is clicked
    @IBAction func cancelClicked(_ sender: Any) {
        self.removePopup()
    }
    
    // when the done button is clicked, attempt to create post
    @IBAction func doneClicked(_ sender: Any) {
        // TODO
    }
}

