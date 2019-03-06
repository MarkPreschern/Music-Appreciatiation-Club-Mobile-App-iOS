//
//  TextFieldCredentials.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/3/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

class TextFieldCredentials: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 1
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
