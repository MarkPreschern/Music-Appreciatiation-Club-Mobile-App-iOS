//
//  GenericItemView.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// the type of controller that we were previously at
enum ControllerType {
    case SearchView
    case AlbumView
}

// Represents a generic item view (song or album)
class GenericItemView: UIViewController {
    
    var itemData : ItemData! // the item's data
    var prevControllerType = ControllerType.SearchView // the item's previous controller type

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
