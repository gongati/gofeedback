//
//  GFFeedbackModel.swift
//  gofeedback
//
//  Created by OMNIADMIN on 25/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation

struct FeedbackModel: Codable {
    
    var userId:String = ""
    var restaurantTitle : String = ""
    var restaurentImage: String?
    var address : String = ""
    var rating : Double = 3
    var whatCanWeDoBetterRating: Double = 3
    var whatAreWeDoingGreatRating: Double = 3
    var howWeAreDoingRating: Double = 3
    var comments : String = ""
    var imageFileName : [String]?
    var videoFilName : [String]?
    var status:FeedbackStatus = .none
    var feedbackId:String?
    var price:Float? = 0.0
    var owners:[String]?
    
    enum CodingKeys: String, CodingKey {
        
        case restaurantTitle = "Restuarant Name"
        case restaurentImage = "Restaurent Image"
        case address = "Restuarant Address"
        case rating = "Rating"
        case whatCanWeDoBetterRating = "What can we do better?"
        case whatAreWeDoingGreatRating = "What are we doing great at?"
        case howWeAreDoingRating = "We want to know how we are doing?"
        case comments = "Comments"
        case imageFileName = "Images"
        case videoFilName = "Videos"
        case status = "Status"
        case userId = "User Id"
        case feedbackId = "Feedback id"
        case price = "Feed Price"
        case owners = "Owners"
    }
}

enum FeedbackStatus: String,Codable {
    
    case Submitted
    case Paid
    case Drafts
    case none
    case Rejected
    case Approved
}
