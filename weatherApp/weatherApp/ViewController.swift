//
//  ViewController.swift
//  weatherApp
//
//  Created by Gevorg Sukiasyan on 8/17/18.
//  Copyright © 2018 Gevorg Sukiasyan. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var cityNameLabel: UILabel!
    var weatherDataManager : WeatherDataManager?
    let session = URLSession.shared
    let collectionCellIdentifier = "WeatherCollectionViewCell"
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0
        
        return _locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupAutocomplete()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        searchController?.searchBar.showsBookmarkButton = true
        searchController?.searchBar.setImage(UIImage(named: "target"), for: .bookmark, state: .normal)
        searchController?.searchBar.delegate = self
        
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func requestWithCity(name: String!) {
        WeatherRequestManager.shared.getWeather(cityName: name, fail: { [weak self] (reason) in
            self?.failWithReason(reason: reason)
        }) { [weak self] (json) in
            self?.weatherDataManager = WeatherDataManager.init(json: json)
            DispatchQueue.main.async {
                self?.weatherCollectionView.reloadData()
            }
        }
    }
    
    func requestWithLocation(location: CLLocation) {
        WeatherRequestManager.shared.getWeather(location: location, fail: { [weak self] (reason) in
            self?.failWithReason(reason: reason)
        }) { [weak self] (json) in
            self?.weatherDataManager = WeatherDataManager.init(json: json)
            let cityName = json["city"]["name"].stringValue
            DispatchQueue.main.async {
                self?.cityNameLabel.text = cityName.isEmpty ? "Current Location" : cityName
                self?.weatherCollectionView.reloadData()
            }
        }
    }
    
    func failWithReason(reason : WeatherError) {
        weatherDataManager = WeatherDataManager()
        DispatchQueue.main.async { [weak self] in
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

extension ViewController : UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
            showActivityIndicator(uiView: view)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController?.searchBar.showsBookmarkButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchController?.searchBar.showsBookmarkButton = true
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            requestWithLocation(location: location)
        } else {
            cityNameLabel.text = "Oops! Something Went Wrong :/"
        }
        hideActivityIndicator()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityNameLabel.text = "Oops! Something Went Wrong :/"
        weatherCollectionView.reloadData()
    }
}
