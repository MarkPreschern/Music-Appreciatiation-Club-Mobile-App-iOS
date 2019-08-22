//
//  ImageAsColor.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/22/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

extension UIColor {
    
    // creates an image of this color with the given size
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    // determines whether the color should be black or white based on the brightness of this color
    func colorByBrightness() -> UIColor {
        let colorComponenets = self.cgColor.components
        let colorBrightness = ((colorComponenets![0] * 299) + (colorComponenets![1] * 587) + (colorComponenets![2] * 114)) / 1000
        if (colorBrightness < 0.5) {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
}


