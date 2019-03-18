//
//  AppDelegate.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/4/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func getDate() -> String{
        let formatter = DateFormatter()
        // to meet specific requirement of the project. Or else I could just use .dateStyle = .short
        formatter.dateFormat = "MM/dd/YYYY"
        let date = Date()
        return formatter.string(from: date)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // REF: https://stackoverflow.com/questions/31966810/count-number-of-times-app-has-been-launched-using-swift
        let defaults = UserDefaults.standard
        let currentCount = defaults.integer(forKey: UserDefaultsKey.currentCount.rawValue)
        defaults.set(String(currentCount), forKey: UserDefaultsKey.currentCountString.rawValue)
        print("Current launch count: ", currentCount)
        // MARK: Request review
        if currentCount == 2 {
            SKStoreReviewController.requestReview()
        }
        // MARK: Set initial launch date
        if currentCount == 0 {
            defaults.set(getDate(), forKey: UserDefaultsKey.initialDate.rawValue)
        }
        
        // MARK: Count value
        defaults.set(currentCount + 1, forKey: UserDefaultsKey.currentCount.rawValue)
        return true
    }
    
}

