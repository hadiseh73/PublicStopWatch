//
//  LocationManager.swift
//  Stopwatch
//
//  Created by HadisehSafaei on 1/28/1402 AP.
//  Copyright © 1402 AP YiGu. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    static let shared = LocationManager()
    var locationManager = CLLocationManager()
    
    
    public func getCurrentLocationData(competion: @escaping (Location,CLLocation) -> Void) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
           
            let location = Location(lon: currentLoc.coordinate.longitude, lat: currentLoc.coordinate.latitude)
            competion(location,currentLoc)
        }
    }
}

