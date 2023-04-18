//
//  LocationModel.swift
//  Stopwatch
//
//  Created by HadisehSafaei on 1/28/1402 AP.
//  Copyright © 1402 AP YiGu. All rights reserved.
//

import Foundation
import CoreLocation

public class Location {
    var lon : CLLocationDegrees
    var lat : CLLocationDegrees
    
    init(lon: CLLocationDegrees, lat: CLLocationDegrees) {
        self.lon = lon
        self.lat = lat
    }
}
