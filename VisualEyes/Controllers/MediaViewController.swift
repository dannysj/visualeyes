//
//  MediaViewController.swift
//  VisualEyes
//
//  Created by Danny Chew on 10/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import AVFoundation

class MediaViewController: UIViewController {
    
    private lazy var mediaView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var player: AVPlayer = {
        let p = AVPlayer()
        return p
    }()
    
    private lazy var downloadButton: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var avPlayerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        }
    }
    
    func initializeMedia() {
        
    }
    
    func initWithPhotoView() {
        self.view.addSubview(mediaView)
        NSLayoutConstraint.activateAllConstraintsEqually(child: mediaView, parent: self.view)
    }
    
    func initWithVideoView() {
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.bounds = self.view.bounds
        avPlayerLayer.frame = self.view.frame
        self.view.layer.insertSublayer(avPlayerLayer, at: 0)
        
    }
    
    func setContentUrl(url: URL) {
        print("Setting up item: \(url)")
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
