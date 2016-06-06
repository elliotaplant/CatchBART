//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit
import CoreLocation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var getDataButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    @IBAction func getDataButtonTriggered(sender: AnyObject) {
        self.locationManager.startUpdatingLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getWeatherFromApi(latitude: String, longitude: String) {
        let latLong = "lat=" + latitude + "&lon=" + longitude
        print(latLong)
        // Bart API url:
        //        http://api.bart.gov/api/etd.aspx?cmd=etd&orig=POWL&key=Q44H-5655-9ALT-DWE9
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?" + latLong + "&APPID=6050c80ccbcf4ab2a284bad41b2d6ba8")
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let location = manager.location as CLLocation? {
            let latitude = String(format: "%.2f", location.coordinate.latitude)
            let longitude = String(format: "%.2f", location.coordinate.longitude)
            getWeatherFromApi(latitude, longitude: longitude)
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
 
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
}

