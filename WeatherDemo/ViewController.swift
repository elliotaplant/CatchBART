//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Properties:
    var destinations = [Destination]()
    
    let stationsInfoParser = StationsInfoParser()
    let stationEDTParser = StationEDTParser()
    let locator = Locator()
    
    var location = Coord(lat: 0, long: 0)
    var bartStationsInfo = [String:Coord]()
    var stations = [Station]()
    var nearestStation = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locator.viewController = self
        
        // get bart stations info
        self.getBartStationsInfo()
        
        // get user location
        self.getUserLocation()
        
        // MARK: - Header View styling
        
        headerView.layer.zPosition = 1;
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.3
        headerView.layer.shadowOffset = CGSizeZero
        headerView.layer.shadowRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "DestinationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DestinationTableViewCell
        // Fetches the appropriate meal for the data source layout.
        let destination = destinations[indexPath.row]
        
        cell.nameLabel.text = destination.name
        cell.time0Label.text = destination.times.count > 0 ? destination.times[0] : ""
        cell.time1Label.text = destination.times.count > 1 ? destination.times[1] : ""
        cell.time2Label.text = destination.times.count > 2 ? destination.times[2] : ""
        
        if (destination.times.count > 0 && Int(destination.times[0]) < 10) {
            cell.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
        } else {
            cell.layer.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2).CGColor
        }

        return cell
    }
    
    // Getting Station Info
    func getBartStationsInfo() {
        self.stations = stationsInfoParser.getBartStationsInfo();
    }
    
    func getUserLocation() {
        self.locator.beginLocating()
    }
    
    func findNearestStationOuter(userLocation: Coord) {
        if nearestStation.coord.lat == 0 {
            nearestStation = findNearestStation(userLocation, stations: stations)
        }
        // request edt from nearest station
        self.getScheduleForStation(nearestStation.abbr)
    }
    
    func getScheduleForStation(stationAbbr: String) {
        destinations += stationEDTParser.getStationEDTs(stationAbbr)
        tableView.reloadData()
    }
}


