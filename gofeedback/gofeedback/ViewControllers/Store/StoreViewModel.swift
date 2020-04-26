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
    
    func buyItems(_ list:[FeedbackModel], _ completion: (( Bool) -> ())?) {
        
        if let userId =  UserDefaults.standard.string(forKey: "UserId") {
            
            let dg = DispatchGroup()
            var failed = false
            for feed in list {
                dg.enter()
                var feed = feed
                var owners = [String]()
                if let owner = feed.owners {
                    owners = owner
                }
                owners.append(userId)
                feed.owners = owners
                feed.price = (feed.price ?? 0.0) + 0.5
                feed.status = .Paid
                GFFirebaseManager.updateFeedStatus(feed.feedbackId ?? "", feed) { (value) in
                    
                    if !value {
                        failed = true
                    }
                    dg.leave()
                }
            }
            dg.notify(queue: .main) {
                
                if failed {
                    
                    completion?(false)
                } else {
                    
                    completion?(true)
                }
            }
        }
    }
    
    func loadAcceptedItems(_ completion:(()->())?) {
        
        if let userId =  UserDefaults.standard.string(forKey: "UserId") {
            GFFirebaseManager.loadApprovedFeeds(userId) { (feedbackModel) in
                
                if let feedbackModel = feedbackModel {
                    
                    self.acceptedItems = feedbackModel
                    completion?()
                } else {
                    
                    print("error")
                }
            }
        }
    }
    
    func loadOwnedItems(_ completion:(()->())?) {
        
        if let userId =  UserDefaults.standard.string(forKey: "UserId") {
            
            GFFirebaseManager.loadOwnedItems(userId) { (feedbackModel) in
                
                if let feedbackModel = feedbackModel {
                    
                    self.ownedItems = feedbackModel
                    completion?()
                } else {
                    
                    print("error")
                }
            }
        }
    }
}
