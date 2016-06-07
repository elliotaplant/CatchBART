//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var getDataButton: UIButton!
    

    let stationsInfoParser = StationsInfoParser()
    let stationEDTParser = StationEDTParser()
    let locator = Locator()
    
    var location = Coord(lat: 0, long: 0)
    var bartStationsInfo = [String:Coord]()
    var stations = [Station]()
    var nearestStation = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))

    @IBAction func getDataButtonTriggered(sender: AnyObject) {
        locator.beginLocating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locator.viewController = self
        
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
        // display etd info
    }
    
    func getScheduleForStation(stationAbbr: String) {
//        getScheudleFromURL("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=" + stationAbbr + "&key=Q44H-5655-9ALT-DWE9");
        stationEDTParser.getStationEDTs(stationAbbr)
    }
    
    // Weather info
    func getWeatherFromApi(latitude: String, longitude: String) {
        let latLong = "lat=" + latitude + "&lon=" + longitude
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?" + latLong + "&APPID=6050c80ccbcf4ab2a284bad41b2d6ba8")
    }
    

    
    func getScheudleFromURL(urlString: String){
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setLabels(data!)
            })
        }
        
        task.resume()
    }

    func getWeatherData(urlString: String) {
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setLabels(data!)
            })
        }
        
        task.resume()
    }

    func setLabels(weatherData: NSData) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            if let name = json[("name")] as? String {
                cityNameLabel.text = name
            }
            if let main = json[("main")] as? NSDictionary {
                if let temp = main[("temp")] as? Double {
                    //convert kelvin to farenhiet
                    let tempFarenheit = (temp * 9/5 - 459.67)
                    
                    cityTempLabel.text = String(format: "%.1f", tempFarenheit)
                    
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    // Get Location

}

