//
//  StoreViewModel.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 25/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation

class StoreViewModel {
    
    var acceptedItems:[FeedbackModel]?
    var ownedItems:[FeedbackModel]?
    
    init(feedItems:[FeedbackModel] = []) {

        //Filter and compute above properties
    }
    
    func buyItems(list:[FeedbackModel] = [], _ completion: (( Bool) -> ())?) {
        
        //Update feed items with the current user ID
        //owner = [userID]
    }
}
