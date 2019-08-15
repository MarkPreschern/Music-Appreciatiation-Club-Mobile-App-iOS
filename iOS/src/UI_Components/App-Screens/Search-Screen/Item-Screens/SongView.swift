//
//  SongView.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/2/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

var player : AVAudioPlayer?
var session : AVAudioSession?

// Represents a view controller for display information about and playing a song
class SongView: GenericItemView {
    
    @IBOutlet weak var background_outlet: UIImageView!
    @IBOutlet weak var mainImage_outlet: UIImageView!
    @IBOutlet weak var songTitle_outlet: UILabel!
    @IBOutlet weak var backButton_outlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets song image and name information in view
        self.background_outlet.image = self.itemData.image
        self.mainImage_outlet.image = self.itemData.image
        self.songTitle_outlet.text = self.itemData.name
        
        // sets background preferences
        self.background_outlet.layer.borderWidth = 1
        self.background_outlet.layer.borderColor = UIColor.black.cgColor
        
        // makes back button's background color transparent
        self.backButton_outlet.backgroundColor = UIColor.clear
        
        //initializes the audio session
        session = AVAudioSession.sharedInstance()
        try! session?.setCategory(AVAudioSession.Category.playback)

        // prepares to play this song
        if (self.itemData.previewUrl != nil) {
            // downloads and prepares song, waiting for a callback to remove loading screen
            self.showSpinner(onView: self.view)
            DispatchQueue.global(qos: .userInitiated).sync {
                self.downloadFileFromURL(url: URL(string: self.itemData.previewUrl)!, completion: { (callback) -> Void in
                    if (callback == "Complete") {
                        self.removeSpinner()
                    }
                })
            }
        }
    }
    
    // downloads the file from the given url and prepares to play it
    func downloadFileFromURL(url: URL, completion: @escaping (String) -> Void) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            
            self.prepareToPlay(url: customURL!)
            completion("Complete")
        })
        downloadTask.resume()
    }
    
    // prepares to play the song url
    func prepareToPlay(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player!.prepareToPlay()
            player!.pause()
        } catch {
            print("Error info: \(error)")
            let alert = createAlert(
                title: "Audio Error",
                message: "\(error)",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // changes the player state from play to puase or visa versa
    @IBAction func changePlayerState(_ sender: Any) {
        if (self.itemData.previewUrl == nil) {
            let alert = createAlert(
                title: "Play Error",
                message: "Song doesn't have a preview, can't be played",
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
        } else if (player == nil) {
            let alert = createAlert(
                title: "Play Error",
                message: "Player hasn't been initialized, please wait",
                actionTitle: "Try Again")
            self.present(alert, animated: true, completion: nil)
        } else {
            if (player!.isPlaying) {
                player!.pause()
                // TODO: change button appearance to "play" image
            } else {
                player!.play()
                // TODO: change button appearance to "pause" image
            }
        }
    }
    
    // goes back to previous view controller when the back button is clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        // determines which controller to navigate to
        switch(self.prevControllerType) {
        case .AlbumView:
            let albumView = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? GenericItemView
            albumView?.prevControllerType = ControllerType.SearchView
            self.present(albumView!, animated:true, completion: nil)
        case .SearchView:
            let searchView = self.storyboard!.instantiateViewController(withIdentifier: "searchScreenID")
            self.present(searchView, animated:true, completion: nil)
        }
    }
}
