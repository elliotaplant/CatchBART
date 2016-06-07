//
//  Helpers.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import Foundation


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
}

func findNearestStation(userLocation: Coord, stations: [Station]) -> Station {
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
    
    return nearestStation;
}

func distBetween(a: Coord, b: Coord) -> Float {
    return (((a.lat - b.lat)**2 + (a.long - b.long)**2)**0.5)
}

infix operator ** { associativity left precedence 170 }

func ** (num: Float, power: Float) -> Float{
    return pow(num, power)
}
