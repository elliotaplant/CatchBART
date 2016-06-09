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
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        self.tableView.backgroundColor = UIColor.clearColor()
        
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
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let tableViewHeaderHeight = 30
//        let DynamicView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, CGFloat(tableViewHeaderHeight)))
//        DynamicView.backgroundColor = UIColor.lightGrayColor()
//        
//        let label1Width = 100.0
//        let label1 = UILabel(frame: CGRectMake(0, 0, CGFloat(label1Width), 20))
//        label1.center = CGPointMake(CGFloat(5 + label1Width/2), CGFloat(tableViewHeaderHeight/2))
//        label1.textAlignment = NSTextAlignment.Left
//        label1.text = "Destination"
//        label1.textColor = UIColor.darkGrayColor()
//        DynamicView.addSubview(label1)
//        
//        let label2Width = 200.0
//        let label2 = UILabel(frame: CGRectMake(0, 0, CGFloat(label2Width), 20))
//        label2.center = CGPointMake(self.view.frame.size.width - CGFloat(5 + label2Width/2), CGFloat(tableViewHeaderHeight/2))
//        label2.textAlignment = NSTextAlignment.Right
//        label2.text = "Minutes to Departure"
//        label2.textColor = UIColor.darkGrayColor()
//
//        DynamicView.addSubview(label2)
//
//        return DynamicView
//    }
    
    func setTimeLabel(label: UILabel, time: String, number: Int) {
        label.text = time
        label.layer.cornerRadius = number == 0 ? 47/2 : 26/2

        if time != "" {
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.lightGrayColor().CGColor
            
            if time.intValue < travelTimes.running {
                label.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
            } else if time.intValue < travelTimes.walking {
                label.layer.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.2).CGColor
            } else {
                label.layer.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2).CGColor
            }
        } else {
            label.layer.borderWidth = 0
            label.layer.borderColor = UIColor.clearColor().CGColor
            label.layer.backgroundColor = UIColor.clearColor().CGColor
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
        destinations = stationEDTParser.getStationEDTs(stationAbbr)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Pull to refresh
    func handleRefresh(refreshControl: UIRefreshControl) {
        getUserLocation()
    }
}


