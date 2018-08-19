//
//  WeatherManager.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/19/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation

enum WeatherError: Error {
    case requestFailed
    case noData
}

class WeatherManager {
    
    static let shared = WeatherManager()
    
    let session = URLSession.shared
    fileprivate let APIKey = "1cb8f3063e4b8ba7e9d5af908b920281"
    fileprivate let baseURLPath = "https://api.openweathermap.org/data/2.5/forecast?"
    
    fileprivate init() {}
    
    typealias WeatherCompletionSuccess = (JSON) -> Void
    typealias WeatherCompletionFail = (WeatherError) -> Void
    
    func getWeather(cityName: String!, fail: @escaping WeatherCompletionFail, success:@escaping WeatherCompletionSuccess) {
        let url = URL(string: baseURLPath + "q=" + cityName + "&units=metric&APPID=" + APIKey)
        
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
                success(json)
            } catch {
                fail(.noData)
            }
            }.resume()
    }
}
