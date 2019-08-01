//
//  TextFieldCredentials.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 7/28/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents custom text field information for the start screen text fields
class TextFieldCredentials: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 9, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
