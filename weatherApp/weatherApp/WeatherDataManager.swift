//
//  WeatherDataManager.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/20/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation

class WeatherDataManager {
    
    var days : [WeatherDayData] = []
    
    init() {}
    
    init(json : JSON?) {
        if json != nil && !(json?.isEmpty)! {
            let weatherArray = json!["list"].arrayObject as! [[String: Any]]
            for dictionary in weatherArray {
                let weatherDay = WeatherDayData.init(dictionary: dictionary)
                days.append(weatherDay)
            }
        }
    }
}
