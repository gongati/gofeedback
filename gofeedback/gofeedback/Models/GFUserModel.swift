//
//  GFUserModel.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 21/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation

struct UserModel:Codable {

    //List all the user details here
    let email:String
    let firstName:String
    let lastName:String
    let mobileNumber:String
    let address:String
    let userType:Int
    var uniqueId:String?
    
    enum CodingKeys: String, CodingKey {
        
        case email = "Email"
        case firstName = "First Name"
        case lastName = "Last Name"
        case mobileNumber = "Mobile Number"
        case address = "Address"
        case userType = "User Type"
        case uniqueId = "Unique Id"
    }
}
