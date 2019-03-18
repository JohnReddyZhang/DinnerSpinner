//
//  RestaurantService.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/6/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation



class RestaurantService {
    static let shared = RestaurantService()
    let imageCache = NSCache<AnyObject, AnyObject>()
    private init() {}
    
    // REF: https://developer.apple.com/documentation/foundation/bundle/1413477-infodictionary
    let apiKey = Bundle.main.infoDictionary!["YelpApiKey"] as! String
    
    private var session = URLSession.shared
    private var dataTask: URLSessionDataTask?
    private let baseUrlString = "https://api.yelp.com/v3/businesses/"
    
    func retrieveARestaurant(for id: String, completion: @escaping (RestaurantDetail?, Error?) -> ()) {
        guard var url = URL(string: baseUrlString) else { return }
        url.appendPathComponent(id)
        
        // According to assignment session notes
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        requestInformation(with: urlRequest, using: RestaurantDetail.self, completion: completion)
    }
    
    
    func searchForRestaurantsAt(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (RestaurantResults?, Error?) -> ()){
        
        // REF: According to assignment session notes
        // REF: https://stackoverflow.com/questions/46597422/adding-http-headers-and-parameters-in-swift4
        var urlComp = URLComponents(string: baseUrlString + "search")
        urlComp?.queryItems = [URLQueryItem(name: "latitude", value: String(latitude)),
                               URLQueryItem(name: "longitude", value: String(longitude)),
                               URLQueryItem(name: "categories", value: "restaurants"),
                               URLQueryItem(name: "open_now", value: "true")]
        var urlRequest = URLRequest(url: (urlComp?.url)!)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "Authorization")
        requestInformation(with: urlRequest, using: RestaurantResults.self, completion: completion)
        
    }
    
    // REF: https://hackernoon.com/ios-image-caching-swift-4-22471342e6c1 for image caching
    func downloadImage(from imageUrlString: String, completion: @escaping (UIImage?, Error?) -> ()){
        guard let url = URL(string: imageUrlString) else { return }
        let placeholder = #imageLiteral(resourceName: "placeholder")
        if let imageFromCache = imageCache.object(forKey: imageUrlString as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                completion(imageFromCache, nil)
            }
        }
        
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async {
                    // Could not find image, using placeholder instead.
                    completion(placeholder, error)
                }
                return
            }
            
            print("Status code for image request: \(response.statusCode)")
            
            DispatchQueue.main.async {
                if let imageToCache = UIImage(data: data){
                    self.imageCache.setObject(imageToCache, forKey: imageUrlString as AnyObject)
                    completion(imageToCache, nil)
                }
            }
            
        })
        dataTask?.resume()
        
    }
    
    private func requestInformation<T: Decodable>(with urlRequest: URLRequest, using decodeProtocol: T.Type, completion: @escaping (T?, Error?) -> ()) {
        dataTask = session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print("Status code: \(response.statusCode)")
            
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(decodeProtocol.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData, nil)
                }
            } catch let (error) {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        dataTask?.resume()
        
    }
}
