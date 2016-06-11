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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var location = Coord(lat: 0, long: 0)
    var bartStationsInfo = [String:Coord]()
    var stations = [Station]()
    var nearestStation = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))
    var travelTimes = TravelTimes(driving: 0, walking: 0, running: 0)
    var currentModeOfTransportation = ModeOfTransportation.Walking
    var travelTime = 0
    var defaultColor = UIColor(red: 14, green: 122, blue: 254)
    
    @IBOutlet weak var drivingTime: UILabel!
    @IBOutlet weak var drivingMins: UILabel!
    @IBOutlet weak var drivingImage: UIImageView!
    @IBOutlet weak var runningTime: UILabel!
    @IBOutlet weak var runningMins: UILabel!
    @IBOutlet weak var runningImage: UIImageView!
    @IBOutlet weak var walkingTime: UILabel!
    @IBOutlet weak var walkingMins: UILabel!
    @IBOutlet weak var walkingImage: UIImageView!

    @IBAction func drivingButtonAction(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Driving)
    }
    @IBAction func runningButtonAction(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Running)
    }
    @IBAction func walkingActionButton(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Walking)
    }
    
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
        appDelegate.viewController = self
        
        // get bart stations info
        self.getBartStationsInfo()
        
        // get user location
        self.getUserLocation()
        
        // Set up travel time indicaiton
        changeModeOfTransportation(ModeOfTransportation.Walking)
        
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
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.blackColor().CGColor
            
            if time.intValue < travelTime {
                label.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
            } else if time.intValue < travelTime + 5 {
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
        
        nearestStation = findNearestStation(userLocation, stations: stations, travelTimes: &travelTimes)
        
        headerLabel.text = nearestStation.name
        
        drivingTime.text = String(travelTimes.driving)
        runningTime.text = String(travelTimes.running)
        walkingTime.text = String(travelTimes.walking)
        
        changeModeOfTransportation(currentModeOfTransportation)
        
        self.getScheduleForStation(nearestStation)
    }
    
    func getScheduleForStation(station: Station) {
        destinations = stationEDTParser.getStationEDTs(station.abbr)
        self.headerLabel.text = station.name
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Pull to refresh
    func handleRefresh(refreshControl: UIRefreshControl) {
        getUserLocation()
    }
    
    // Change mode of transportation
    func changeModeOfTransportation(mode: ModeOfTransportation) {
        currentModeOfTransportation = mode
        
        drivingTime.textColor = UIColor.blackColor()
        drivingMins.textColor = UIColor.blackColor()
        runningTime.textColor = UIColor.blackColor()
        runningMins.textColor = UIColor.blackColor()
        walkingTime.textColor = UIColor.blackColor()
        walkingMins.textColor = UIColor.blackColor()
        
        walkingImage.image = UIImage(named: "Walking")
        runningImage.image = UIImage(named: "Running")
        drivingImage.image = UIImage(named: "Driving")
        
        switch mode {
        case ModeOfTransportation.Walking:
            travelTime = travelTimes.walking
            walkingImage.image = UIImage(named: "one-man-walking-selected")
            walkingTime.textColor = defaultColor
            walkingMins.textColor = defaultColor
        case ModeOfTransportation.Running:
            travelTime = travelTimes.running
            runningImage.image = UIImage(named: "man-sprinting-selected")
            runningTime.textColor = defaultColor
            runningMins.textColor = defaultColor
        case ModeOfTransportation.Driving:
            travelTime = travelTimes.driving
            drivingImage.image = UIImage(named: "car-trip-selected")
            drivingTime.textColor = defaultColor
            drivingMins.textColor = defaultColor
        }
        
        tableView.reloadData()
    }
    
    // Set Error message
    func setErrorMessage(errorMessage: String) {
        self.headerLabel.text = errorMessage
    }
}


