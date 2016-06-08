//
//  Location.swift
//  WeatherDemo
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
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
    func beginLocating() {
        print("in BL")
        self.locationManager.requestLocation()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let location = manager.location as CLLocation? {
            print("could cast location")
            userLocation.lat = Float(location.coordinate.latitude)
            userLocation.long = Float(location.coordinate.longitude)
            self.viewController!.findNearestStationOuter(userLocation)
        } else {
            print("could not cast location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    
}