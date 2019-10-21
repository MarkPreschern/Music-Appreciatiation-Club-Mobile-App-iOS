//
//  PopupScreen.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 10/21/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// protocol for all popup screens
protocol PopupScreen: UIViewController {
    
    // shows the popup screen and waits for a callback
    func showPopup(callback: @escaping (String) -> Void) -> Void
    
    // removes the popup screen
    func removePopup() -> Void
}
