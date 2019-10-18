//
//  SettingsScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/11/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents user settings
class SettingsScreenMain: UIViewController {
    
    @IBOutlet weak var table_outlet: UITableView!
    @IBOutlet weak var view_outlet: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets view border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }

    // returns to the profile screen when clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "profileScreenID")
        self.present(nextVC, animated:true, completion: nil)
    }
}
