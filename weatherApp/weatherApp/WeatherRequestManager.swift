//
//  WeatherManager.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/19/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherRequestManager {
    
    static let shared = WeatherRequestManager()
    
    let session = URLSession.shared
    fileprivate let APIKey = "1cb8f3063e4b8ba7e9d5af908b920281"
    fileprivate let baseURLPath = "https://api.openweathermap.org/data/2.5/forecast?"
    
    fileprivate init() {}
    
    typealias WeatherCompletionSuccess = (JSON) -> Void
    typealias WeatherCompletionFail = (WeatherError) -> Void
    
    func getWeather(cityName: String!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherCompletionSuccess) {
        let trimmedCityName = cityName.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: baseURLPath + "q=" + trimmedCityName + "&units=metric&APPID=" + APIKey)
        if url == nil {
            fail(.unknownError)
            return
        }
        getWeather(url: url, fail: fail, success: success)
    }
    
    func getWeather(location: CLLocation, fail: @escaping WeatherCompletionFail, success:@escaping WeatherCompletionSuccess) {
        let lat:String = "\(location.coordinate.latitude)"
//        var token = lat.components(separatedBy: ".")
//        lat = token[0]
        let lon:String = "\(location.coordinate.longitude)"
//        token = lon.components(separatedBy: ".")
//        lon = token[0]
        let url = URL(string: baseURLPath + "lat=" + lat + "&lon=" + lon + "&units=metric&APPID=" + APIKey)
        if url == nil {
            fail(.unknownError)
            return
        }
        getWeather(url: url, fail: fail, success: success)
    }
    
    func getWeather(url : URL!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherCompletionSuccess) {
        session.dataTask(with: url!) { data, URLResponse, requestError in
            guard let data = data else {
                if let _ = requestError {
                    fail(.requestFailed)
                } else {
                    print("data is nil, but there is no error!")
                }
                
                return
            }
            
            do {
                let json = try JSON(data: data)
                if json["cod"].stringValue == "200" {
                    success(json)
                } else if json["message"].stringValue == "city not found" {
                    fail(.cityNotFound)
                } else {
                    fail(.unknownError)
                }
                
            } catch {
                fail(.noData)
            }
            }.resume()
    }
}
