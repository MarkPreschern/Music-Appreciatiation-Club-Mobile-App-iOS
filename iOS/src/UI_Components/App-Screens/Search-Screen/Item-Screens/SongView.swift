//
//  SongView.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/2/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

class SongView: GenericItemView {
    
    @IBOutlet weak var background_outlet: UIImageView!
    
    @IBOutlet weak var mainImage_outlet: UIImageView!
    
    @IBOutlet weak var songTitle_outlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // sets song image and name information in view
        self.background_outlet.image = self.itemImage
        self.mainImage_outlet.image = self.itemImage
        self.songTitle_outlet.text = self.itemName
        
        // sets back button preferences
        background_outlet.layer.borderWidth = 1
        background_outlet.layer.borderColor = UIColor.black.cgColor
    }
    
}
