//
//  GFAdminFeedListViewCell.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 27/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import SnapKit
import CDYelpFusionKit
import Cosmos

class GFAdminFeedListViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var tickBtn: UIButton!
    @IBOutlet weak var imageFlagBtn: UIButton!
    @IBOutlet weak var videoFlagBtn: UIButton!
    
    func updateCell(model: FeedbackModel) {
        
        self.resetCell()
        
        self.titleLabel.text = model.restaurantTitle
        self.descLabel.text = model.comments
        self.starView.rating = model.rating
        self.addressLabel.text = model.address
    
        if model.status == .Approved || model.status == .Paid {
            
            self.tickBtn.isHidden = false
        } else if model.status == .Rejected {
            
            self.crossBtn.isHidden = false
        }
        
        if let images = model.imageFileName, images.count > 0 {
            
            self.imageFlagBtn.isHidden = false
        }
        
        if let videos = model.videoFilName, videos.count > 0 {
            
            self.videoFlagBtn.isHidden = false
        }
    }
    
    func resetCell() {
        
        self.crossBtn.isHidden = true
        self.tickBtn.isHidden = true
        self.imageFlagBtn.isHidden = true
        self.videoFlagBtn.isHidden = true
        self.starView.rating = 1
        
        self.logoImage.backgroundColor = .gray
    }
    
}
