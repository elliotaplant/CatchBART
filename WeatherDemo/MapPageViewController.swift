//
//  MapPageViewController.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/9/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class MapPageViewController: UIViewController {

    @IBOutlet weak var redKey: UIView!
    @IBOutlet weak var yellowKey: UIView!
    @IBOutlet weak var greenKey: UIView!
    var keys = [UIView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keys = [self.redKey, self.yellowKey, self.greenKey]
        
        for key in keys {
            key.layer.borderWidth = 1
            key.layer.cornerRadius = 35/2
            key.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
