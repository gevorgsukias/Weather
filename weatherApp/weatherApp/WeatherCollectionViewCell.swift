//
//  WeatherCollectionViewCell.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/21/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func setupWithWeatherDayData(day: WeatherDayData!) {
        let temperature = day.temperature.stringValue
        var token = temperature.components(separatedBy: ".")
        temperatureLabel.text = token[0] + " °C"
        var date: String = day.date
        date = String(date.dropLast(3))
        dateLabel.text = date
        weatherLabel.text = day.weather
        weatherDescriptionLabel.text = day.weatherDescription
    }
}
