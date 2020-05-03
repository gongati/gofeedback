//
//  GFYelpManager.swift
//  gofeedback
//
//  Created by OMNIADMIN on 02/05/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation
import CDYelpFusionKit

class GFYelpManager {
    
   private static let yelpAPIClient = CDYelpAPIClient(apiKey: "JuFWYKLiETl9O-z6Tn7ysBeGyXbzON1Eh-_lbP56VDbu5YdZMRLQTBE2rNWfLCCM85Ot21lMMhiW9GsuaEVAg8kBQLPPVoAaTFP99Fm3m9_2WHMBibfkoItNQhuLXnYx")
    
    static func yelpSearch(byTerm: String?,location:String?,latitude:Double?,longitude:Double?, radius:Int?,_ completion: (((CDYelpSearchResponse)?) -> ())?) {
        
        yelpAPIClient.searchBusinesses(byTerm: byTerm,
                                       location: location,
                                       latitude: latitude,
                                       longitude: longitude,
                                       radius: radius,
                                       categories: nil,
                                       locale: .english_unitedStates,
                                       limit: 50,
                                       offset: nil,
                                       sortBy: .bestMatch,
                                       priceTiers: nil,
                                       openNow: nil,
                                       openAt: nil,
                                       attributes: nil) { (response) in
                                        
                                        if let response = response {
                                            
                                            completion?(response)
                                        } else {
                                            
                                            completion?(nil)
                                        }
        }
        
    }
    
    static func yelpSearchCancelRequests() {
        
        yelpAPIClient.cancelAllPendingAPIRequests()
    }
}
