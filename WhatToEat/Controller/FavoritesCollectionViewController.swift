//
//  FavoritesCollectionViewController.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/6/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "RestaurantItem"

class FavoritesCollectionViewController: UICollectionViewController {
    var favoriteRestaurants: [Restaurant] = []
    // let restaurantService = RestaurantService()
    let suchEmptyLabel = UILabel()
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    private let itemsPerRow: CGFloat = 2
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    @objc func updateData() {
        suchEmptyLabel.text = "Wow, such empty.\nYour favorited restaurants\nwill be shown here"
        suchEmptyLabel.textAlignment = .center
        suchEmptyLabel.numberOfLines = 0
        suchEmptyLabel.sizeToFit()
        suchEmptyLabel.center = self.view.center
        if let fetchedData = UserDefaults.standard.data(forKey: UserDefaultsKey.favorites.rawValue) {
            self.favoriteRestaurants = try! PropertyListDecoder().decode([Restaurant].self, from: fetchedData)
            suchEmptyLabel.removeFromSuperview()
        } else {
            self.view.addSubview(suchEmptyLabel)
        }
        collectionView.reloadData()
    }
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favoriteRestaurants.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoritesCollectionViewCell
        let restaurant = self.favoriteRestaurants[indexPath.row]
        cell.RestaurantName.text = restaurant.name
        cell.RestaurantImage.image = #imageLiteral(resourceName: "loading")
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageUrl = restaurant.image_url{
                RestaurantService.shared.downloadImage(from: imageUrl,
                                                       completion: { (resultImage, error) in
                                                        guard let image = resultImage else { return }
                                                        cell.RestaurantImage.image = image
                })
            }
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailViewController = segue.destination as? DetailCardViewController else { return }
        guard let cell = sender as? FavoritesCollectionViewCell else { return }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let restaurant = self.favoriteRestaurants[indexPath.row]
        detailViewController.restaurant = restaurant
    }
    
}

// REF: https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started
extension FavoritesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
