//
//  GFFirebaseManager.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 20/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation
import Firebase

class GFFirebaseManager {
    
    //Have ths common inititalisers and setup here
    
    static func loadAllFeeds(_ completion: (() -> [FeedbackModel])?) {
        
    }
    
    static func loadFeedsForUser(userName: String, _ completion: (() -> [FeedbackModel])?) {
        
    }
    
    //We should create a model class for User and it should hold all usewr related details
    static func getUserdetails(userName: String, _ completion: (() -> UserModel)?) {
        
        
    }
    
    static func updateFeedStatus(feed: FeedbackModel, _ completion: (() -> Bool)?) {
        
        
    }
    
    //Also see if there are anu other methods that can be moved here
}
