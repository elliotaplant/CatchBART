//
//  APIkey.example.swift
//  CatchBART
//
//  Created by Elliot Plant on 6/11/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

// To use your own BART API key, copy this file and save the copy as API.swift
// Make sure to delete API.example.swift after you copy it to avoid a 'Invalid Redeclaration' error
import Foundation

class API {
    let baseUrl = "http://api.bart.gov/api/"
    
    // Replace this with your own bart API key
    // You can get an API key from http://api.bart.gov/api/register.aspx
    let key = "MW9S-E7SL-26DU-VV8V" // This is the public bart api key. Please don't hog it.
}
