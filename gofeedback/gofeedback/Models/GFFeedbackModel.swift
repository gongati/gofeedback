//
//  GFFeedbackModel.swift
//  gofeedback
//
//  Created by OMNIADMIN on 25/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation

struct FeedbackModel {
    
    var restaurantTitle = ""
    var address = ""
    var rating : Double = 3
    var whatCanWeDoBetterRating: Double = 3
    var whatAreWeDoingGreatRating: Double = 3
    var howWeAreDoingRating: Double = 3
    var comments = ""
    var searchItem = ""
    var imageFileName = [""]
    var formFilName = ""
    var isSubmitBtnHidden = false
    var status:FeedbackStatus = .none
}

enum FeedbackStatus: String {
    
    case Submitted
    case Paid
    case Drafts
    case none
}
