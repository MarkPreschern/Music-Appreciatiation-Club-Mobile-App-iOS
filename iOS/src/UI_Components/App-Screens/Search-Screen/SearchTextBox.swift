//
//  SearchTextBox.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 7/28/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// Represents the search text box
class SearchTextBox: UITextField {
    
    // initialization on view loading
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        self.returnKeyType = UIReturnKeyType.search
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 12)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
