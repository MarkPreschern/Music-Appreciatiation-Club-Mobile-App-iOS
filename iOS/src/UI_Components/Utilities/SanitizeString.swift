//
//  SanitizeString.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 11/15/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// sanitizes the given string such that it can be correctly passed through API Gateway, Mac API Lambda, and the Database
extension String {

    func sanitize() -> String {
        var text = self.replacingOccurrences(of: "‘", with: "'")
        text = text.replacingOccurrences(of: "’", with: "'")
        text = text.replacingOccurrences(of: "“", with: "\"")
        text = text.replacingOccurrences(of: "”", with: "\"")
        
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-/:;()$&@\".,?!'[]{}#%^*+=_\\|~<>")
        return String(text.filter {okayChars.contains($0) })
    }
    
}
