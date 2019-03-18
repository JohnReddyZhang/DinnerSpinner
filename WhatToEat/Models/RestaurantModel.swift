//
//  FoodClass.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/5/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import Foundation

// REF: Struct based on yelp fusion documentation https://www.yelp.com/developers/documentation/v3
struct RestaurantResults: Codable {
    var total: Int?
    var businesses: [Restaurant]?
    var region: Coordinates?
}

struct Restaurant: Codable {
    let name: String?
    let id: String?
    let image_url: String?
}

struct RestaurantDetail: Codable {
    let name: String?
    let rating: Float?
    //    let price: String?
    let image_url: String?
    let phone: String?
    let display_phone: String?
    let categories: [Categories]?
    let review_count: Int?
    
    let url: URL?
    let coordinates: Coordinates?
    let location: Location?
    
}

struct Categories: Codable {
    let alias: String?
    let title: String?
}

struct Location: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
    let display_address: [String]
}

struct Coordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

