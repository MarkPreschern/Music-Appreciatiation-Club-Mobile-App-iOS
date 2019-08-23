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
class SongView: UIViewController {
    
    @IBOutlet weak var background_outlet: UIImageView!
    @IBOutlet weak var mainImage_outlet: UIImageView!
    @IBOutlet weak var songTitle_outlet: UILabel!
    @IBOutlet weak var backButton_outlet: UIButton!
    @IBOutlet weak var addButton_outlet: UIButton!
    @IBOutlet weak var playPause_outlet: UIButton!
    
    var songData : ItemData! // the item's data
    var albumData : ItemData! // the song's album's data if applicable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets song image and name information in view
        self.background_outlet.image = self.songData.image.averageColor()!.image(self.songData.image.size)
        self.mainImage_outlet.image = self.songData.image
        self.songTitle_outlet.text = self.songData.name
        
        // sets background preferences
        self.background_outlet.layer.borderWidth = 1
        self.background_outlet.layer.borderColor = UIColor.black.cgColor
        
        // makes back and add button's background color transparent
        self.backButton_outlet.backgroundColor = UIColor.clear
        self.addButton_outlet.backgroundColor = UIColor.clear
        
        //determines the color (black/white) of text and buttons based on the song image
        let color = self.songData.image.averageColor()!.colorByBrightness()
        self.backButton_outlet.setTitleColor(color, for: UIControl.State.normal)
        self.addButton_outlet.setTitleColor(color, for: UIControl.State.normal)
        self.songTitle_outlet.textColor = color
        self.playPause_outlet.setTitleColor(color, for: UIControl.State.normal)
        
        //initializes the audio session
        session = AVAudioSession.sharedInstance()
        try! session?.setCategory(AVAudioSession.Category.playback)

        // prepares to play this song
        if (self.songData.previewUrl != nil) {
            // downloads and prepares song, waiting for a callback to remove loading screen
            self.showSpinner(onView: self.view)
            DispatchQueue.global(qos: .userInitiated).sync {
                self.downloadFileFromURL(url: URL(string: self.songData.previewUrl)!, completion: { (callback) -> Void in
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
            player!.numberOfLoops = -1 //loops forever
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
        if (self.songData.previewUrl == nil) {
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
                player!.fadeOut()
                self.playPause_outlet.setTitle("Play", for: UIControl.State.normal)
            } else {
                player!.fadeIn()
                self.playPause_outlet.setTitle("Pause", for: UIControl.State.normal)
            }
        }
    }
    
    // goes back to previous view controller when the back button is clicked
    @IBAction func backButtonClicked(_ sender: Any) {
        //resets the audio player after fading
        player!.fadeOut()
        player = AVAudioPlayer()
        // determines which controller to navigate to
        if (self.albumData == nil) {
            let searchView = self.storyboard!.instantiateViewController(withIdentifier: "searchScreenID")
            self.present(searchView, animated:false, completion: nil)
        } else {
            let albumView = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? AlbumView
            albumView?.albumData = self.albumData
            self.present(albumView!, animated:false, completion: nil)
        }
    }
    
    // when the add button is clicked, create an item alert for this song
    @IBAction func addButtonClicked(_ sender: Any) {
        UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            .addItemAlert(name: self.songData.name, type: ItemType.SONG, item: self.songData, sender: self)
    }
}
