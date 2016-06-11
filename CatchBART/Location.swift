//
//  Location.swift
//  CatchBART
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import Foundation
import CoreLocation

class Locator: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var userLocation = Coord(lat: 0, long: 0)
    var viewController : ViewController?
    var locationAttempts = 0
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
    func beginLocating() {
        self.locationManager.requestLocation()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location as CLLocation? {
            self.locationAttempts = 0
            self.locationManager.stopUpdatingLocation()
            userLocation.lat = Float(location.coordinate.latitude)
            userLocation.long = Float(location.coordinate.longitude)
            self.viewController!.findNearestStationOuter(userLocation)
        } else if self.locationAttempts > 5 {
            self.viewController?.setErrorMessage("Could not find location")
        } else {
            self.locationAttempts += 1
            self.locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error: " + error.localizedDescription)
    }
    
    
}