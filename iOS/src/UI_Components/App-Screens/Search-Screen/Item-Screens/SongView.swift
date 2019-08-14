//
//  SongView.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 8/2/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import AVFoundation

// Represents a view controller for display information about and playing a song
class SongView: GenericItemView {
    
    @IBOutlet weak var background_outlet: UIImageView!
    @IBOutlet weak var mainImage_outlet: UIImageView!
    @IBOutlet weak var songTitle_outlet: UILabel!
    @IBOutlet weak var backButton_outlet: UIButton!
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets song image and name information in view
        self.background_outlet.image = self.itemData.image
        self.mainImage_outlet.image = self.itemData.image
        self.songTitle_outlet.text = self.itemData.name
        
        // sets back button preferences
        background_outlet.layer.borderWidth = 1
        background_outlet.layer.borderColor = UIColor.black.cgColor
        
        // makes back button's background color transparent
        self.backButton_outlet.backgroundColor = UIColor.clear
        
        // prepares to play this song
        print(self.itemData.previewUrl)
        if (self.itemData.previewUrl == nil) {
            // TODO : Tell user there is no preview for this song
            print("Error: Null previewURL")
        } else {
            self.downloadFileFromURL(url: URL(string: self.itemData.previewUrl)!)
        }
    }
    
    // downloads the file from the given url and prepares to play it
    func downloadFileFromURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            
            self.prepareToPlay(url: customURL!)
        })
        downloadTask.resume()
    }
    
    // prepares to play the song url
    func prepareToPlay(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player!.prepareToPlay()
            player!.play()
        } catch {
            print("Error info: \(error)")
            fatalError()
        }
    }
    
    // changes the player state from play to puase or visa versa
    @IBAction func changePlayerState(_ sender: Any) {
        if (self.itemData.previewUrl == nil) {
            // TODO : Tell user there is no preview for this song
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
        print("changing view")
        
        // determines which controller to navigate to
        switch(self.prevControllerType) {
        case .AlbumView:
            let albumView = self.storyboard!.instantiateViewController(withIdentifier: "albumViewID") as? GenericItemView
            albumView?.prevControllerType = ControllerType.SearchView
            
            // TODODODODODODODODO
            
            self.present(albumView!, animated:true, completion: nil)
        case .SearchView:
            let searchView = self.storyboard!.instantiateViewController(withIdentifier: "searchScreenID")
            self.present(searchView, animated:true, completion: nil)
        }
    }
}
