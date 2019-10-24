//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the news screen. Holds information regarding:
// - club related news and reminders
class NewsScreenMain: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var view_outlet: UIView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
}
