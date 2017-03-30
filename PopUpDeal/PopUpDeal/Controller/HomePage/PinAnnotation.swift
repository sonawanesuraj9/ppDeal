//
//  PinAnnotation.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/4/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import MapKit
import Foundation


class PinAnnotation: NSObject,MKAnnotation {
    
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.331705, longitude: -122.030237)
    
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
//    
//    var title: String = ""
//    var subtitle: String = ""
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
}
