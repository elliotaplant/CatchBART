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
    var travelTimes = TravelTimes(driving: 0, walking: 0, running: 0)
    
    @IBOutlet weak var drivingTime: UILabel!
    @IBOutlet weak var runningTime: UILabel!
    @IBOutlet weak var walkingTime: UILabel!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
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
        headerView.layer.shadowOffset = CGSizeMake(0.0, 6.0)
        headerView.layer.shadowRadius = 3
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
        setTimeLabel(cell.time0Label, time: destination.times[0], number: 0)
        setTimeLabel(cell.time1Label, time: destination.times[1], number: 1)
        setTimeLabel(cell.time2Label, time: destination.times[2], number: 2)

        return cell
    }
    
    func setTimeLabel(label: UILabel, time: String, number: Int) {
        label.text = time
        label.layer.cornerRadius = number == 0 ? 47/2 : 26/2
        if time != "" {
            if time.intValue < 5 {
                label.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
            } else if time.intValue < 10 {
                label.layer.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.2).CGColor
            } else {
                label.layer.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2).CGColor
            }
        }
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
            nearestStation = findNearestStation(userLocation, stations: stations, travelTimes: &travelTimes)
        }
        headerLabel.text = nearestStation.name
        
        drivingTime.text = String(travelTimes.driving) + " mins"
        runningTime.text = String(travelTimes.running) + " mins"
        walkingTime.text = String(travelTimes.walking) + " mins"
        
        self.getScheduleForStation(nearestStation.abbr)
    }
    
    func getScheduleForStation(stationAbbr: String) {
        if destinations.count == 0 {
            destinations = stationEDTParser.getStationEDTs(stationAbbr)
            tableView.reloadData()
        }
    }
}


