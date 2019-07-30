//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the profile screen. Holds information regarding:
// - User information (name, nuid)
// - User's top picks (songs & albums)
class ProfileScreenMain: UIViewController {
    
    @IBOutlet weak var view_outlet: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
}

