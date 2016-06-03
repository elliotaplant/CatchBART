//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=London,uk")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var jsonError: NSError?
        
        let json = NSJSONSerialization.JSONObjectWithData(weatherData, options: nil, error: &jsonError) as NSDictionary
        
        if let name = json["name"] as? String {
            cityNameLabel.text = name
        }
        
        if let main = json["main"] as? NSDictionary {
            if let temp = main["temp"] as? Double {
                cityTempLabel.text = String(format: "%.1f", temp)
            }
        }
        
    }
}

