//
//  ViewController.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/17/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var cityNameLabel: UILabel!
    var weatherDataManager : WeatherDataManager?
    let session = URLSession.shared
    let collectionCellIdentifier = "WeatherCollectionViewCell"
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupAutocomplete()
        setupNavigationController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCollectionView() {
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        weatherCollectionView.register(UINib(nibName: "WeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: collectionCellIdentifier)
    }
    
    func setupAutocomplete() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        resultsViewController?.autocompleteFilter = filter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
//    func setCityName(name: String!) {
//        while (cityNameLabel.text != nil && !(cityNameLabel.text?.isEmpty)!) {
//            cityNameLabel.text?.removeLast()
//        }
//
//        for i in 0...name.count - 1 {
//        }
//    }
    
    func requestWithCity(name: String!) {
        WeatherRequestManager.shared.getWeather(cityName: name, fail: { [weak self] (reason) in
            self?.weatherDataManager = WeatherDataManager()
            DispatchQueue.main.async {
                switch reason {
                case .cityNotFound:
                    self?.cityNameLabel.text = "City Not Found :/"
                case .noData:
                    self?.cityNameLabel.text = "No Data :/"
                case .requestFailed:
                    self?.cityNameLabel.text = "Request Failed :/"
                case .unknownError:
                    self?.cityNameLabel.text = "Oops! Something Went Wrong :/"
                }
                self?.weatherCollectionView.reloadData()
            }
        }) { [weak self] (json) in
            self?.weatherDataManager = WeatherDataManager.init(json: json)
            DispatchQueue.main.async {
                self?.weatherCollectionView.reloadData()
            }
        }
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weatherDataManager?.days.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath)
        
        if let cell = c as? WeatherCollectionViewCell {
            cell.setupWithWeatherDayData(day: self.weatherDataManager?.days[indexPath.row])
        }
        
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(12, 0, 84, 0)
    }
}

extension ViewController : GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        cityNameLabel.text = place.name
        requestWithCity(name: place.name)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
