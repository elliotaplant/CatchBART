//
//  Helpers.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import Foundation
import UIKit

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
    
    travelTimes.driving = Int(max(3.554*log(leastDistance)/log(2.71828) + 5, 2))
    travelTimes.walking = Int(max(15.275*leastDistance+5.12, 2))
    travelTimes.running = max(travelTimes.running/2, 2)
    
    return nearestStation;
}

func distBetween(a: Coord, b: Coord) -> Float {
    return (((a.lat - b.lat)**2 + (a.long - b.long)**2)**0.5)
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
