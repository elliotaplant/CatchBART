//
//  ViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/3/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var getDataButton: UIButton!
    @IBAction func getDataButtonTriggered(sender: AnyObject) {
        getWeatherFromApi()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherFromApi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getWeatherFromApi() {
        let cityName = cityNameTextField.text!.removeWhitespace()
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=" + cityName + ",us&APPID=<INSERT_API_KEY_HERE>")
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
}

