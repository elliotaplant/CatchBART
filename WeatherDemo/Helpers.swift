//
//  Helpers.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var intValue: Int {
        return Int((self as NSString).intValue)
    }
}

func findNearestStation(userLocation: Coord, stations: [Station], inout travelTimes: TravelTimes) -> Station {
    var nearestStation = Station(name: "No Nearby Station", abbr: "NNST", coord: Coord(lat: 0, long: 0))
    var leastDistance = Float.infinity
    var currentDist : Float
    
    for station in stations {
        currentDist = distBetween(userLocation, b: station.coord)
        if currentDist < leastDistance {
            leastDistance = currentDist
            nearestStation = station
        }
    }
    
    travelTimes.driving = Int(max(leastDistance * 0.007, 2))
    travelTimes.walking = Int(max(leastDistance * 0.020, 2))
    travelTimes.running = max(Int(Double(travelTimes.walking) * 0.72), 2)
    return nearestStation;
}

func distBetween(a: Coord, b: Coord) -> Float {
    let aloc = CLLocation(latitude: CLLocationDegrees(a.lat), longitude: CLLocationDegrees(a.long))
    let bloc = CLLocation(latitude: CLLocationDegrees(b.lat), longitude: CLLocationDegrees(b.long))
    
    return Float(aloc.distanceFromLocation(bloc))
}




infix operator ** { associativity left precedence 170 }

func ** (num: Float, power: Float) -> Float{
    return pow(num, power)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
