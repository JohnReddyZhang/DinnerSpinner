//
//  FakeInitialViewController.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/5/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import UIKit
import CoreLocation

class InitialDataLoadingViewController: UIViewController {
    let locationMngr = CLLocationManager()
    var restaurants: [Restaurant] = []
    
    @IBOutlet weak var versionAndBuildLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        versionAndBuildLabel.text = "Version: \(version ?? "N/A")"
        
        locationMngr.delegate = self
        locationMngr.desiredAccuracy = kCLLocationAccuracyBest
        checklocationAuth()
        locationMngr.requestLocation()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainView = segue.destination as? UITabBarController else { return }
        let decideView = mainView.viewControllers?[0] as! DecideViewController
        decideView.restaurants = restaurants
    }
    
    // MARK: - Populate Restaurants
    func populateRestaurants(near location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        RestaurantService.shared.searchForRestaurantsAt(latitude: latitude, longitude: longitude) { (restaurants, error) in
            if let result = restaurants, error == nil {
                // use total if necessary
                self.restaurants = result.businesses!
                self.performSegue(withIdentifier: "initialSegue", sender: self)
            }
            else {
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.locationMngr.requestLocation()
                })
                self.alertFor(type: .networkErr, actions: [action])
                return
            }
        }
    }
}

// MARK: - Location Management
// REF: https://www.ioscreator.com/tutorials/request-permission-core-location-ios-tutorial
extension InitialDataLoadingViewController: CLLocationManagerDelegate{
    func checklocationAuth() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationMngr.requestWhenInUseAuthorization()
            return
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .denied, .restricted:
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            let goToAction = UIAlertAction(title: "Go to Settings", style: .default) { (UIAlertAction) in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            self.alertFor(type: .restricedLocation , actions: [okAction, goToAction])
            
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentlocation = locations.last else { return }
        print(currentlocation)
        populateRestaurants(near: currentlocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertFor(type: .locationDisabled, actions: nil)
    }
}
