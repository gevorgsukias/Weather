//
//  ViewController.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/17/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let session = URLSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func weatherBtnPressed(_ sender: UIButton) {
        WeatherManager.shared.getWeather(cityName: "London", fail: { (error) in
            
        }) { (json) in
            print(json)
        }
    }
}

