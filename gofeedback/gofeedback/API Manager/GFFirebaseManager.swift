//
//  GFFirebaseManager.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 20/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GFFirebaseManager {
    
    //Have ths common inititalisers and setup here
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage()
    
    static func loadAllFeeds(_ completion: ((([FeedbackModel])?) -> ())?) {
        
        let query = self.db.collection("Feedback")
        
         query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion?(nil)
            } else if let documents = querySnapshot?.documents   {
                
                var feedbackModel = [FeedbackModel]()
                
                for document in documents {
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data() as Any, options: []) else {
                        print(err!)
                        return }
                    guard var feedBackModel = try? JSONDecoder().decode(FeedbackModel.self, from: data) else {
                        print(err!)
                        return
                    }
                    feedBackModel.feedbackId = document.documentID
                    if feedBackModel.status != .Drafts {
                    feedbackModel.append(feedBackModel)
                    }
                }
                let alphabatedSortedFeeds = feedbackModel.sorted { (a,b) in
                    
                    return a.restaurantTitle < b.restaurantTitle
                }
                completion?(alphabatedSortedFeeds)
            }
        }
    }
    
    static func loadFeedsForUser(userId: String,_ state:String, _ completion: ((([FeedbackModel])?) -> ())?) {
        
        let query = self.db.collection("Feedback")
            .whereField(Constants.FeedbackCommands.userId, isEqualTo: userId)
            .whereField(Constants.FeedbackCommands.status, isEqualTo: state)
         
         query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion?(nil)
            } else if let documents = querySnapshot?.documents   {
                
                var feedbackModel = [FeedbackModel]()
                
                for document in documents {
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data() as Any, options: []) else {
                        print(err!)
                        return }
                    guard var feedBackModel = try? JSONDecoder().decode(FeedbackModel.self, from: data) else {
                        
                        print(err!)
                        return
                    }
                    feedBackModel.feedbackId = document.documentID
                    feedbackModel.append(feedBackModel)
                }
                let timeSortedFeeds = feedbackModel.sorted { (a,b) in
                    
                    if state == FeedbackStatus.Drafts.rawValue {
                        
                        return (a.timeStamp ?? 0) > (b.timeStamp ?? 0)
                    } else {
                        
                        return a.restaurantTitle < b.restaurantTitle
                    }
                }
                completion?(timeSortedFeeds)
            }
        }
    }
    
    //We should create a model class for User and it should hold all usewr related details
    static func getUserdetails(userName: String, _ completion: (((UserModel)?) -> ())?) {
        
        let docRef = db.collection("Users").document(userName)
        
        docRef.getDocument { (document, error) in
            let result = Result {
                try document.flatMap {
                    try $0.data(as: UserModel.self)
                }
            }
            switch result {
            case .success(let user):
                if let user = user {
                   
                    completion?(user)
                } else {
                    print("Document does not exist")
                    completion?(nil)
                }
            case .failure(let error):
                print("Error decoding city: \(error)")
            }
        }

    }
    
    static func updateFeedStatus(_ feedId:String,_ feed: FeedbackModel, _ completion: ((Bool) -> ())?) {
        
        do {
            
            let docRef = db.collection("Feedback").document(feedId)
            let _ =  try docRef.setData(from: feed)
            completion?(true)
        } catch {
         
            print("Error writing user to Firestore: \(error)")
            completion?(false)
        }
    }
    
    //Also see if there are anu other methods that can be moved here
    
    static func creatingUserDetails(userModel:UserModel, _ completion: ((Bool) -> ())?) {
        
        do {
            
            let newCityRef = db.collection("Users").document()
            let _ =  try newCityRef.setData(from: userModel)
            var userModels = userModel
            userModels.uniqueId = newCityRef.documentID
            GFUserDefaults.settingUserDetails(userModels)
            completion?(true)
        } catch let error {
            
            print("Error writing user to Firestore: \(error)")
            completion?(false)
        }
    }
    
    static func isUserHasRegistered(userId:String,_ completion: ((Bool) -> ())?) {
        
        let query = self.db.collection("Users").whereField(Constants.userDetails.mobileNumber, isEqualTo: userId)
        
        query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if querySnapshot?.documents.count == 0 {
                    
                    completion?(true)
                    
                } else {
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: querySnapshot?.documents[0].data() as Any, options: []) else {
                        print(err!)
                        return }
                    guard let usermodel = try? JSONDecoder().decode(UserModel.self, from: data) else {
                        
                        print(err!)
                        return
                    }
                    var userModels = usermodel
                    userModels.uniqueId = querySnapshot?.documents[0].documentID
                    GFUserDefaults.settingUserDetails(userModels)
                    print("query = \(String(describing: querySnapshot?.documents))")
                    
                    completion?(false)
                }
            }
        }
    }
    
    static func creatingFeedBack(feedbackModel:FeedbackModel,_ completion: (( Bool) -> ())?) {
        do {
            
            let docRef = db.collection("Feedback").document()
            let _ =  try docRef.setData(from: feedbackModel)
            completion?(true)
        } catch {
         
            print("Error writing user to Firestore: \(error)")
            completion?(false)
        }
    }
    
    static func uploadImage(image: UIImage,_ path:String, _ completion: (( Bool) -> ())?) {
        
        let imageData = image.jpegData(compressionQuality: 0.1)
        let uploadRef = storage.reference().child(path)
        _ = uploadRef.putData(imageData!, metadata: nil) { metadata,
            error in
            
            if error == nil {
                
                completion?(true)
            } else {
                
                completion?(false)
            }
        }
    }
    
    static func uploadVideo(url:URL,_ path:String, _ completion: (( Bool) -> ())?) {
        
        let uploadRef = storage.reference().child(path)
        _ = uploadRef.putFile(from: url, metadata: nil) { metadata, error in
            
            if error == nil {
                
                completion?(true)
            } else {
                
                completion?(false)
            }
        }
    }
    
    static func downloadImage(_ path:String,_ completion: (((UIImage)?) -> ())?) {
        
        let pathReferenceOfImages = self.storage.reference(withPath: path )
        pathReferenceOfImages.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if error != nil {
                
                print(error!.localizedDescription)
                completion?(nil)
            } else {
                
                let image = UIImage(data: data!)
                if let image = image {
                    
                    completion?(image)
                }
            }
        }
    }
    
    static func downloadVideoUrl(_ path:String,_ completion: (((URL)?) -> ())?) {
        
        let pathReferenceOfVideos = self.storage.reference(withPath: path )
        pathReferenceOfVideos.downloadURL { url, error in
            
            if error != nil {
                completion?(nil)
                print(error!.localizedDescription)
            } else {
                if let url = url {
                   completion?(url)
                }
            }
        }
    }
    
    static func loadApprovedFeeds(_ userId:String,_ completion: ((([FeedbackModel])?) -> ())?) {
        
        let query = self.db.collection("Feedback")
            .whereField(Constants.FeedbackCommands.status, isEqualTo: FeedbackStatus.Approved.rawValue)
         
         query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion?(nil)
            } else if let documents = querySnapshot?.documents {
                
                var feedbackModel = [FeedbackModel]()
                
                for document in documents {
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data() as Any, options: []) else {
                        print(err!)
                        return }
                    guard var feedBackModel = try? JSONDecoder().decode(FeedbackModel.self, from: data) else {
                        print(err!)
                        return
                    }
                    feedBackModel.feedbackId = document.documentID
                    if !(feedBackModel.owners?.contains(userId) ?? false) {
                        feedbackModel.append(feedBackModel)
                    }
                }
                
                let alphabatedSortedFeeds = feedbackModel.sorted { (a,b) in
                    
                    return a.restaurantTitle < b.restaurantTitle
                }
                completion?(alphabatedSortedFeeds)
            }
        }
    }
    
    static func loadOwnedItems(_ userId:String,_ completion: ((([FeedbackModel])?) -> ())?) {
        
        let query = self.db.collection("Feedback")
            .whereField(Constants.FeedbackCommands.status, isEqualTo: FeedbackStatus.Paid.rawValue)
            .whereField(Constants.FeedbackCommands.owners, arrayContains: userId)
         
         query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion?(nil)
            } else if let documents = querySnapshot?.documents {
                
                var feedbackModel = [FeedbackModel]()
                
                for document in documents {
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data() as Any, options: []) else {
                        print(err!)
                        return }
                    guard var feedBackModel = try? JSONDecoder().decode(FeedbackModel.self, from: data) else {
                        print(err!)
                        return
                    }
                    feedBackModel.feedbackId = document.documentID
                    feedbackModel.append(feedBackModel)
                }
                let alphabatedSortedFeeds = feedbackModel.sorted { (a,b) in
                    
                    return a.restaurantTitle < b.restaurantTitle
                }
                completion?(alphabatedSortedFeeds)
            }
        }
    }
}


class GFUserDefaults {
    
    static func settingUserDetails(_ userModel:UserModel) {
        
        UserDefaults.standard.set( userModel.firstName + " " + userModel.lastName, forKey: "UserName")
        UserDefaults.standard.set(userModel.email, forKey: "Email")
        UserDefaults.standard.set("\(userModel.userType)", forKey: "UserType")
        UserDefaults.standard.set(userModel.uniqueId, forKey: "UserId")
         UserDefaults.standard.synchronize()
    }
    
    static func removingUserDefaults() {
        
        UserDefaults.standard.set(false, forKey: "loginStatus")
        UserDefaults.standard.removeObject(forKey: "UserId")
        UserDefaults.standard.set("",forKey: "UserName")
        UserDefaults.standard.set("",forKey: "email")
        UserDefaults.standard.removeObject(forKey: "UserType")
        UserDefaults.standard.synchronize()
    }
}
