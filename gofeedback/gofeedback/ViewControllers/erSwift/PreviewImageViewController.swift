//
//  PreviewImageViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 04/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PreviewImageViewController: UIViewController {

    var image : UIImage?
    var isVideo: Bool?
    var videoUrl : URL?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // isVideo = true
        if (isVideo ?? false) {
            
            self.imageView.removeFromSuperview()
        } else {
            
        self.imageView.image = image
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if (isVideo ?? false) {
          
//            guard let path = Bundle.main.path(forResource: "video", ofType:"mp4") else {
//                debugPrint("video.m4v not found")
//                return
//            }
            if let videoURL =  self.videoUrl {//URL(fileURLWithPath: path)
                let player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.bounds
                self.view.layer.addSublayer(playerLayer)
                player.play()
            }
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
