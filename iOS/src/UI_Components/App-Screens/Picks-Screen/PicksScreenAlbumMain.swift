//
//  PicksScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the picks screen. Holds information regarding:
// - continously updated album top picks across the entire club
// - ability to vote on songs and albums
class PicksScreenAlbumMain: UIViewController {
    
    // user picked songs
    var picksUserAlbumItems = [ItemData]()
    // club picked songs
    var picksClubAlbumItems = [ItemData]()
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var songLabel_outlet: UIButton!
    @IBOutlet weak var albumLabel_outlet: UIButton!
    @IBOutlet weak var myPicksView_outlet: UIView!
    @IBOutlet weak var clubPicksView_outlet: UIView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets myPicks and clubPicks borders
        self.myPicksView_outlet.layer.borderWidth = 1
        self.myPicksView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        self.clubPicksView_outlet.layer.borderWidth = 1
        self.clubPicksView_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets task song and album borders just on the top and bottom
        self.songLabel_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.songLabel_outlet.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.albumLabel_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        self.albumLabel_outlet.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        
        //sets song and album button colors
        self.songLabel_outlet.backgroundColor = UIColor.white
        self.albumLabel_outlet.backgroundColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 0.5)
    }
    
}

