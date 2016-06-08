//
//  DestinationInfoTableViewCell.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {

    // Properties:
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var time0Label: UILabel!
    @IBOutlet weak var time1Label: UILabel!
    @IBOutlet weak var time2Label: UILabel!

    //    @IBOutlet weak var time0Label: UILabel!
    //    @IBOutlet weak var time1Label: UILabel!
    //    @IBOutlet weak var time2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
