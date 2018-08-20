//
//  WeatherDayData.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/20/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation

class WeatherDayData {
    
    var temperature : NSNumber!
    var minTemperature : NSNumber!
    var maxTemperature : NSNumber!
    var weather : String!
    var weatherDescription : String!
    
    init(dictionary : [String: Any]) {
        let main: [String: Any] = dictionary["main"] as! [String: Any]
        temperature = main["temp"] as! NSNumber
        minTemperature = main["temp_min"] as! NSNumber
        maxTemperature = main["temp_max"] as! NSNumber
        
        let weatherArray = dictionary["weather"] as! [Any]
        let weatherDict = weatherArray.first as! [String: Any]
        weather = weatherDict["main"] as! String
        weatherDescription = weatherDict["description"] as! String
    }
}
