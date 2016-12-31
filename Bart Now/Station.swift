//
//  Station.swift
//  Bart Now
//
//  Created by Dustin Chan on 12/31/16.
//  Copyright © 2016 Dustin Chan. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(stationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = stationName
        self.subtitle = stationName
        self.coordinate = coordinate
        
        super.init()
    }

}
