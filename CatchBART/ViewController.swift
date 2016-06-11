//
//  ViewController.swift
//  CatchBART
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let stationsInfoParser = StationsInfoParser()
    let stationEDTParser = StationEDTParser()
    
    let locator = Locator()
    var location = Coord(lat: 0, long: 0)
    
    var bartStationsInfo = [String:Coord]()
    var stations = [Station]()
    var destinations = [Destination]()
    var nearestStation = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))
    
    var currentModeOfTransportation = ModeOfTransportation.Walking
    var travelTimes = TravelTimes(driving: 0, walking: 0, running: 0)
    var travelTime = 0
    
    // View outlets
    @IBOutlet weak var drivingTime: UILabel!
    @IBOutlet weak var drivingMins: UILabel!
    @IBOutlet weak var drivingImage: UIImageView!
    @IBOutlet weak var runningTime: UILabel!
    @IBOutlet weak var runningMins: UILabel!
    @IBOutlet weak var runningImage: UIImageView!
    @IBOutlet weak var walkingTime: UILabel!
    @IBOutlet weak var walkingMins: UILabel!
    @IBOutlet weak var walkingImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    // View actions
    @IBAction func drivingButtonAction(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Driving)
    }
    @IBAction func runningButtonAction(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Running)
    }
    @IBAction func walkingActionButton(sender: AnyObject) {
        changeModeOfTransportation(ModeOfTransportation.Walking)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Add refresh controlls to tableview
        self.tableView.addSubview(self.refreshControl)
        
        // Initialize travel time indicaiton
        changeModeOfTransportation(ModeOfTransportation.Walking)
        
        // Apply styles
        self.tableView.backgroundColor = UIColor.clearColor()
        headerView.layer.zPosition = 1;
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.3
        headerView.layer.shadowOffset = CGSizeMake(0.0, 6.0)
        headerView.layer.shadowRadius = 3
        
        // Distribute references to this ViewController
        locator.viewController = self
        appDelegate.viewController = self
        
        // Begin API logic
        self.getBartStationsInfo()
        self.getUserLocation() // kicks off API action chain
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView display
    // ==============================================================================
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Set up re-usable table cells
        let cellIdentifier = "DestinationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DestinationTableViewCell
        
        // Get appropriate destination to display
        let destination = destinations[indexPath.row]
        
        // Fill out cell with destination values
        cell.nameLabel.text = destination.name
        setTimeLabel(cell.time0Label, time: destination.times[0], number: 0)
        setTimeLabel(cell.time1Label, time: destination.times[1], number: 1)
        setTimeLabel(cell.time2Label, time: destination.times[2], number: 2)

        return cell
    }
    
    func setTimeLabel(label: UILabel, time: String, number: Int) {
        
        label.text = time
        
        // First time is larger than the others
        label.layer.cornerRadius = number == 0 ? 47/2 : 26/2
        
        if time != "" {
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.blackColor().CGColor
            
            // Color code times based on travel time to station
            if time.intValue < travelTime {
                label.layer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
            } else if time.intValue < travelTime + 5 {
                label.layer.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.2).CGColor
            } else {
                label.layer.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2).CGColor
            }
        } else {
            
            // Don't display non-existant times
            label.layer.borderWidth = 0
            label.layer.borderColor = UIColor.clearColor().CGColor
            label.layer.backgroundColor = UIColor.clearColor().CGColor
        }
    }
    
    // API Logic
    // ==============================================================================
    func getBartStationsInfo() {
        self.stations = stationsInfoParser.getBartStationsInfo();
    }
    
    func getUserLocation() {
        self.locator.beginLocating()
    }
    
    func findNearestStationOuter(userLocation: Coord) {
        
        // Use helper to find nearest station
        nearestStation = findNearestStation(userLocation, stations: stations, travelTimes: &travelTimes)
        
        // Update UI with nearest station data
        headerLabel.text = nearestStation.name
        
        drivingTime.text = String(travelTimes.driving)
        runningTime.text = String(travelTimes.running)
        walkingTime.text = String(travelTimes.walking)
        
        changeModeOfTransportation(currentModeOfTransportation)
        
        self.getScheduleForStation(nearestStation)
    }
    
    func getScheduleForStation(station: Station) {
        
        // Call bart API for station schedule
        destinations = stationEDTParser.getStationEDTs(station.abbr)
        
        // Update UI with nearest station name
        self.headerLabel.text = station.name
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Pull to refresh
    // ==============================================================================
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getUserLocation()
    }
    
    // Change mode of transportation
    func changeModeOfTransportation(mode: ModeOfTransportation) {
        currentModeOfTransportation = mode
        
        // Reset all of the text colors on the header
        drivingTime.textColor = UIColor.blackColor()
        drivingMins.textColor = UIColor.blackColor()
        runningTime.textColor = UIColor.blackColor()
        runningMins.textColor = UIColor.blackColor()
        walkingTime.textColor = UIColor.blackColor()
        walkingMins.textColor = UIColor.blackColor()
        
        // Reset transportation icons
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
        
        // Re-draw the table
        tableView.reloadData()
    }
    
    // Set Error message
    func setErrorMessage(errorMessage: String) {
        self.headerLabel.text = errorMessage
    }
}


