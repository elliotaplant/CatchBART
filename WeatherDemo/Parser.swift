//
//  Parser.swift
//  WeatherDemo
//
//  Created by Elliot Plant on 6/7/16.
//  Copyright © 2016 Elliot Plant. All rights reserved.
//

import Foundation

class StationsInfoParser: NSObject, NSXMLParserDelegate {
    var parser = NSXMLParser()
    var stations = [Station]()
    var element = NSString()
    var name = NSMutableString()
    var abbr = NSMutableString()
    var station = Station(name: "", abbr: "", coord: Coord(lat: 0, long: 0))

    func getBartStationsInfo() -> Array<Station> {
        stations = []
        parser = NSXMLParser(contentsOfURL:(NSURL(string:"http://api.bart.gov/api/stn.aspx?cmd=stns&key=Q44H-5655-9ALT-DWE9"))!)!
        parser.delegate = self
        parser.parse()
        return stations
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if (elementName as NSString).isEqualToString("station") {
            station.clear()
            
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if element.isEqualToString("name") {
            station.name = string
        } else if element.isEqualToString("abbr") {
            station.abbr = string
        } else if element.isEqualToString("gtfs_latitude") {
            station.coord.lat = string.floatValue
        } else if element.isEqualToString("gtfs_longitude") {
            station.coord.long = string.floatValue
        }
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("station") {
            stations += [station]
        }
    }
}

class StationEDTParser: NSObject, NSXMLParserDelegate {
    var parser = NSXMLParser()
    var destinations = [Destination]()
    var element = NSString()
    var name = NSMutableString()
    var destination = Destination(name: "", times: [])
    
    func getStationEDTs(stationAbbr: String) -> [Destination] {
        destination.clear()
        parser = NSXMLParser(contentsOfURL:(NSURL(string:"http://api.bart.gov/api/etd.aspx?cmd=etd&orig=" + stationAbbr + "&key=Q44H-5655-9ALT-DWE9"))!)!
        parser.delegate = self
        parser.parse()
        return destinations
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if (elementName as NSString).isEqualToString("etd") {
            destination = Destination(name: "", times: [])
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if element.isEqualToString("destination") {
            destination.name = string
        } else if element.isEqualToString("minutes") {
            destination.times.append(string.intValue)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("etd") {
            destinations += [destination]
        }
    }
}


