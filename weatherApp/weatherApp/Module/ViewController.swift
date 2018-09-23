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
    let collectionCellIdentifier = "WeatherCollectionViewCell"
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    lazy var viewModel: WeatherViewModel = {
        return WeatherViewModel()
    }()
    
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
        
        initVM()
        
        setupCollectionView()
        setupAutocomplete()
        setupNavigationController()
    }
    
    func initVM() {
        
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    if let weakSelf = self {
                        weakSelf.showActivityIndicator(uiView: weakSelf.view)
                    }
                }else {
                    self?.hideActivityIndicator()
                }
            }
        }
        
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let cityName = self?.viewModel.cityName {
                    self?.cityNameLabel.text = cityName.isEmpty ? "Current Location" : cityName
                }
                self?.weatherCollectionView.reloadData()
            }
        }
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
    
    func showAlert( _ message: String ) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestWithCity(name: String!) {
        viewModel.initFetch(cityName: name)
    }

    
    func requestWithLocation(location: CLLocation) {
        viewModel.initFetch(location: location)
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as? WeatherCollectionViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        let cellVM = viewModel.getCellViewModel( at: indexPath )
        
        cell.temperatureLabel.text = cellVM.temperatureText
        cell.dateLabel.text = cellVM.dateText
        cell.weatherLabel.text = cellVM.weatherText
        cell.weatherDescriptionLabel.text = cellVM.weatherDescText
        
        return cell
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
            showAlert("Oops! Something Went Wrong :/")
        }
        hideActivityIndicator()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert("Oops! Something Went Wrong :/")
        weatherCollectionView.reloadData()
    }
}
