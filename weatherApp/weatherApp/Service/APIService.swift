//
//  APIService.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 9/23/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation
import CoreLocation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

enum WeatherError: String, Error {
    case requestFailed = "Request Failed :/"
    case noData = "No Data :/"
    case cityNotFound = "City Not Found :/"
    case unknownError = "Oops! Something Went Wrong :/"
}

typealias WeatherCompletionSuccess = ([WeatherDayData]) -> Void
typealias WeatherLocationCompletionSuccess = ([WeatherDayData], String) -> Void
typealias WeatherCompletionFail = (WeatherError) -> Void

protocol APIServiceProtocol {
    func fetchWeatherData(cityName: String!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherLocationCompletionSuccess)
    func fetchWeatherData(location: CLLocation, fail: @escaping WeatherCompletionFail, success:@escaping WeatherLocationCompletionSuccess)
}

class APIService: APIServiceProtocol {
    
    let session = URLSession.shared
    fileprivate let APIKey = "1cb8f3063e4b8ba7e9d5af908b920281"
    fileprivate let baseURLPath = "https://api.openweathermap.org/data/2.5/forecast?"
    
    func fetchWeatherData(cityName: String!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherLocationCompletionSuccess) {
        let trimmedCityName = cityName.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: baseURLPath + "q=" + trimmedCityName + "&units=metric&APPID=" + APIKey)
        if url == nil {
            fail(.unknownError)
            return
        }
        getWeather(url: url, fail: fail, success: success)
    }
    
    func fetchWeatherData(location: CLLocation, fail: @escaping WeatherCompletionFail, success:@escaping WeatherLocationCompletionSuccess) {
        let lat:String = "\(location.coordinate.latitude)"
        let lon:String = "\(location.coordinate.longitude)"
        let url = URL(string: baseURLPath + "lat=" + lat + "&lon=" + lon + "&units=metric&APPID=" + APIKey)
        if url == nil {
            fail(.unknownError)
            return
        }
        getWeather(url: url, fail: fail, success: success)
    }
    
    func getWeather(url : URL!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherLocationCompletionSuccess) {
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
                    var days : [WeatherDayData] = []
                    let weatherArray = json["list"].arrayObject as! [[String: Any]]
                    for dictionary in weatherArray {
                        let weatherDay = WeatherDayData.init(dictionary: dictionary)
                        days.append(weatherDay)
                    }
                    let cityName = json["city"]["name"].stringValue
                    success(days, cityName)
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
