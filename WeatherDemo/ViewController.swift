//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    let stationsInfoParser = StationsInfoParser()
    let stationEDTParser = StationEDTParser()
    let locator = Locator()
    
    var location = Coord(lat: 0, long: 0)
    var bartStationsInfo = [String:Coord]()
    var stations = [Station]()
    var nearestStation = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locator.viewController = self
        
        // get bart stations info
        print("getting bart info")
        self.getBartStationsInfo()
        
        // get user location
        print("getting user location")
        self.getUserLocation()
        // this will trigger finding the nearest station and displaying info
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Getting Station Info
    func getBartStationsInfo() {
        self.stations = stationsInfoParser.getBartStationsInfo();
        print(self.stations[0])
    }
    
    func getUserLocation() {
        self.locator.beginLocating()
    }
    
    func findNearestStationOuter(userLocation: Coord) {
        print("finding nearest station")
        if nearestStation.coord.lat == 0 {
            nearestStation = findNearestStation(userLocation, stations: stations)
            print("nearest station:", nearestStation)
        }
        // request edt from nearest station
        self.getScheduleForStation(nearestStation.abbr)
    }
    
    func getScheduleForStation(stationAbbr: String) {
        let schedule = stationEDTParser.getStationEDTs(stationAbbr)
        print(schedule)
    }
}

