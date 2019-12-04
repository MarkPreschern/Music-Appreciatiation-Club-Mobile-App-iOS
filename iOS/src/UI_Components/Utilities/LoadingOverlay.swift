//
//  loadingOverlay.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

var vSpinner : UIView?
var vSpinnerControllerRestorationIdentifier : String?

// represents a loading screen spinner than can be shown and removed
extension UIViewController {
    
    // shows the spinner
    func showSpinner(onView : UIView) {
        vSpinner = nil
        vSpinnerControllerRestorationIdentifier = self.restorationIdentifier
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
            
        vSpinner = spinnerView
    }
    
    // removes the spinner if applicable
    func removeSpinner() {
        DispatchQueue.main.async {
            if vSpinnerControllerRestorationIdentifier == self.restorationIdentifier {
                vSpinner?.removeFromSuperview()
            }
            vSpinner = nil
        }
    }
}
