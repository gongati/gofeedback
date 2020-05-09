//
//  GFEnterpriseListViewCell.swift
//  gofeedback
//
//  Created by OMNIADMIN on 09/05/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import SnapKit
import Cosmos

class EnterpriseListViewCell:UITableViewCell {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    
    func updateCell(_ isOwnedItems:Bool,_ model:FeedbackModel) {
        
        self.resetCell()
        
        self.restaurantName.text = model.restaurantTitle
        self.restaurantAddress.text = model.address
        
        if let logoImageUrl = model.restaurentImageUrl {
           
            self.logoImageView.downloaded(from: logoImageUrl)
        } else {
            
            self.logoImageView.image = UIImage(named: "question mark")
        }
        
        if isOwnedItems {
            
            self.ratings.isHidden = false
            self.comments.text = model.comments
            self.ratings.rating = model.rating
        } else {
            
            let wordArray = model.comments.split(separator: " ").map{ String($0) }
            if wordArray.count >= 2 {
                
                self.comments.text = wordArray[0]+wordArray[1]+"..."
            } else {
                
                self.comments.text = ""
            }
        }
    }
    
    func resetCell() {
        
        self.ratings.isHidden = true
        
        self.logoImageView.backgroundColor = .gray
        self.backgroundColor = .white
    }

}
