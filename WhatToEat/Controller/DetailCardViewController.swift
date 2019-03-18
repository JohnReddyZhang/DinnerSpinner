//
//  DetailViewController.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/8/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class DetailCardViewController: UIViewController {
    var favorites: [Restaurant] = []
    var restaurant: Restaurant?
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Properties
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var restuaurantImage: UIImageView!
    @IBOutlet weak var displayPhone: UILabel!
    @IBOutlet weak var addressLine: UILabel!
    @IBOutlet weak var locationOnMap: MKMapView!
    
    @IBOutlet weak var favoriteButtonProperty: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationOnMap.delegate = self
        if let id = self.restaurant?.id {
            RestaurantService.shared.retrieveARestaurant(for: id) { (result, error) in
                if let detail = result, error == nil {
                    self.populateContent(from: detail)
                    self.decideFavoriteStatus(by: id)
                } else {
                    let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.alertFor(type: .networkErr, actions: [dismiss])
                }
            }
        }
    }
    
    func populateContent(from data: RestaurantDetail) {
        restaurantNameLabel.text = data.name ?? "No Name Restaurant"
        ratingImage.image = UIImage(imageLiteralResourceName: String(data.rating ?? 0))
        if let imageUrlString = data.image_url {
            self.restuaurantImage.image = #imageLiteral(resourceName: "loading")
            DispatchQueue.global(qos: .userInitiated).async {
                RestaurantService.shared.downloadImage(from: imageUrlString, completion: { (resultImage, error) in
                    if let image = resultImage, error == nil {
                        self.restuaurantImage.image = image
                    } else if let placeholder = resultImage, error != nil {
                        self.restuaurantImage.image = placeholder
                    }
                })
            }
        }
        
        if let phone = data.display_phone {
            displayPhone.text = phone
        } else {
            displayPhone.isHidden = true
        }
        if let address = data.location?.display_address {
            addressLine.text = address.joined(separator: "\n")
            markOnMap(address: address.joined(separator: ", "), title: data.name ?? "No Name Restaurant")
        }
        
    }
    
    func decideFavoriteStatus(by id: String) {
        if let fetchedData = UserDefaults.standard.data(forKey: UserDefaultsKey.favorites.rawValue) {
            self.favorites = try! PropertyListDecoder().decode([Restaurant].self, from: fetchedData)
        }
        if isFavorite(id) {
            self.favoriteButtonProperty.setImage(#imageLiteral(resourceName: "starred"), for: .normal)
            favoriteButtonProperty.removeTarget(self, action: nil, for: .allEvents)
            favoriteButtonProperty.addTarget(self, action: #selector(removeFromFavorite), for: .touchUpInside)
        } else {
            self.favoriteButtonProperty.setImage(#imageLiteral(resourceName: "star"), for: .normal)
            favoriteButtonProperty.removeTarget(self, action: nil, for: .allEvents)
            favoriteButtonProperty.addTarget(self, action: #selector(addToFavorite), for: .touchUpInside)
        }
    }
    
    func isFavorite(_ id: String) -> Bool {
        let ids = self.favorites.map { $0.id }
        return ids.contains(id)
    }
    
    @objc func addToFavorite() {
        guard let restaurant = self.restaurant else { return }
        guard let id = restaurant.id else { return }
        self.favorites.append(restaurant)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.favorites) , forKey: UserDefaultsKey.favorites.rawValue)
        self.decideFavoriteStatus(by: id)
    }
    
    @objc func removeFromFavorite(){
        guard let id = self.restaurant?.id else { return }
        if let index = self.favorites.firstIndex(where: {$0.id == self.restaurant!.id}) {
            self.favorites.remove(at: index)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.favorites) , forKey: UserDefaultsKey.favorites.rawValue)
        }
        self.decideFavoriteStatus(by: id)
        
    }
}

// REF:https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
// REF: https://stackoverflow.com/questions/9606031/ios-mkmapview-place-annotation-by-using-address-instead-of-lat-long
// REF: https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
// MARK: - Show location on map
extension DetailCardViewController: MKMapViewDelegate{
    func markOnMap(address: String, title: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                self.locationOnMap.setRegion(region, animated: true)
                self.locationOnMap.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = locationOnMap.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let addressDict  = [CNPostalAddressStreetKey: view.annotation?.title]
        let item = MKMapItem(placemark: MKPlacemark(coordinate: (location?.coordinate)!, addressDictionary: addressDict as [String : Any]))
        item.openInMaps(launchOptions: launchOptions)
    }
}
