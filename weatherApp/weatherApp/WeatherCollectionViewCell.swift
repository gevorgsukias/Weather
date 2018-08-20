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

}
