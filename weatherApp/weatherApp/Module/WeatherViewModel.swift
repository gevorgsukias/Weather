//
//  WeatherViewModel.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 9/23/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherCellViewModel {
    let temperatureText: String
    let dateText: String
    let weatherText: String
    let weatherDescText: String
}

class WeatherViewModel {
    let apiService : APIServiceProtocol
    
    private var days : [WeatherDayData] = [WeatherDayData]()
    
    private var cellViewModels: [WeatherCellViewModel] = [WeatherCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var cityName : String? = "Current Location"
    
    var reloadCollectionViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch(cityName: String) {
        self.isLoading = true
        self.cityName = cityName
        apiService.fetchWeatherData(cityName: cityName, fail: { [weak self] (error) in
            self?.alertMessage = error.rawValue
        }) { [weak self] (days, cityName) in
            self?.cityName = cityName
            self?.isLoading = false
            self?.processFetchedWeatherData(days: days)
        }
    }
    
    func initFetch(location: CLLocation) {
        self.isLoading = true
        apiService.fetchWeatherData(location: location, fail: { [weak self] (error) in
            self?.alertMessage = error.rawValue
        }) { [weak self] (days, cityName) in
            self?.cityName = cityName
            self?.isLoading = false
            self?.processFetchedWeatherData(days: days)
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> WeatherCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel( weatherData: WeatherDayData ) -> WeatherCellViewModel {
        let temperature = weatherData.temperature.stringValue
        var token = temperature.components(separatedBy: ".")
        let temperatureText = token[0] + " °C"
        
        var date: String = weatherData.date
        date = String(date.dropLast(3))
        
        return WeatherCellViewModel(temperatureText: temperatureText,
                                    dateText: date,
                                    weatherText: weatherData.weather,
                                    weatherDescText: weatherData.weatherDescription ?? "")
    }
    
    private func processFetchedWeatherData( days: [WeatherDayData] ) {
        self.days = days // Cache
        var vms = [WeatherCellViewModel]()
        for day in days {
            vms.append( createCellViewModel(weatherData: day) )
        }
        self.cellViewModels = vms
    }
}
