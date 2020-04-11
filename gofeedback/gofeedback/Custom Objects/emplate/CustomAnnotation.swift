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
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

