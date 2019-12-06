//
//  FadeOutAudio.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/22/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

var fadingIn : Bool = true

extension AVAudioPlayer {
    
    // fades audio in
    @objc func fadeIn(changeStatus: Bool) {
        fadingIn = changeStatus ? true : fadingIn
        if fadingIn {
            if !self.isPlaying && self.volume == 0.0  {
                // gets the player ready to play at 0.0 volume and play
                self.volume = 0.2
                self.prepareToPlay()
                self.play()
                self.perform(#selector(fadeIn), with: nil, afterDelay: 0.0)
            } else if self.volume < 1.0 {
                // Fade
                self.volume += 0.2
                self.perform(#selector(fadeIn), with: nil, afterDelay: 0.2)
            } else {
                self.volume = 1.0
            }
        }
    }
    
    // fades audio out
    @objc func fadeOut(changeStatus: Bool) {
        fadingIn = changeStatus ? false : fadingIn
        if !fadingIn {
            if self.isPlaying {
                if self.volume > 0.0 {
                    // Fade
                    self.volume -= 0.1
                    self.perform(#selector(fadeOut), with: nil, afterDelay: 0.1)
                } else {
                    // Stop and get the sound ready for playing again
                    self.volume = 0.0
                    self.stop()
                    self.prepareToPlay()
                }
            }
        }
    }
}

