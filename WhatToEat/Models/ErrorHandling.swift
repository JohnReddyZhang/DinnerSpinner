//
//  ErrorTypes.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/7/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import Foundation
import UIKit

enum dataError: Error {
    case networkErr, locationDisabled, restricedLocation, emptyDataError, unhandledError
    
    func provideErrorMessage() -> (title: String, message: String) {
        switch self {
        case .networkErr:
            return ("Network Error", "Please check your network connection.")
        case .locationDisabled:
            return ("Location is Disabled", "Please go to settings app and allow location service.")
        case .restricedLocation:
            return ("Location Services disabled", "Please enable Location Services in Settings")
        case .emptyDataError:
            return ("Data ","")
        default:
            return ("Unhandled Error", "Please tell the developer about that.")
        }
    }
}

extension UIViewController {
    
    func alertFor(type error: dataError, actions: [UIAlertAction]?){
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let body = error.provideErrorMessage()
        let masterAlert = UIAlertController(title: body.title, message: body.message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions{
                masterAlert.addAction(action)
            }
        } else {
            masterAlert.addAction(okAction)
        }
        
        present(masterAlert, animated: true, completion: nil)
    }
    
}
