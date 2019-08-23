//
//  FadeOutAudio.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/22/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

extension AVAudioPlayer {
    
    // fades audio in
    @objc func fadeIn() {
        if !self.isPlaying {
            // gets the player ready to play at 0.0 volume and play
            self.volume = 0.0
            self.prepareToPlay()
            self.play()
            self.perform(#selector(fadeIn), with: nil, afterDelay: 0.0)
        } else if self.volume < 1.0 {
            // Fade
            self.volume += 0.2
            self.perform(#selector(fadeIn), with: nil, afterDelay: 0.2)
        }
    }
    
    // fades audio out
    @objc func fadeOut() {
        if self.volume > 0.0 {
            // Fade
            self.volume -= 0.1
            self.perform(#selector(fadeOut), with: nil, afterDelay: 0.1)
        } else {
            // Stop and get the sound ready for playing again
            self.stop()
            self.prepareToPlay()
            self.volume = 1.0
        }
    }
}

