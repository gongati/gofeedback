//
//  CustomAnnotation.swift
//  gofeedback
//
//  Created by OMNIADMIN on 09/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import MapKit
import CDYelpFusionKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var business: CDYelpBusiness?
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, business: CDYelpBusiness? = nil) {
        self.coordinate = coordinate
        self.business = business
        self.title = business?.name
    }
}

