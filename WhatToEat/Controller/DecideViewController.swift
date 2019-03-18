//
//  FirstViewController.swift
//  WhatToEat
//
//  Created by JohnZhang on 3/4/19.
//  Copyright © 2019 John Zhang. All rights reserved.
//

import UIKit
import CoreLocation

class DecideViewController: UIViewController {
    var spinCount = 0
    var restaurants: [Restaurant] = []
    var result: Restaurant?
    
    @IBOutlet weak var spinLabel: UIButton!
    @IBOutlet weak var showLabel: UIButton!
    // MARK: - Slotmachine properties
    @IBOutlet weak var restaurantSlotMachine: UIPickerView!
    private let repeats = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantSlotMachine.delegate = self
        restaurantSlotMachine.dataSource = self
        styleSpinButton()
        restaurantSlotMachine.isHidden = true
        showLabel.isHidden = true
        restaurantSlotMachine.selectRow((repeats / 2) * restaurants.count, inComponent: 0, animated: false)
    }
    
    // MARK: - Spinning the wheel
    @IBAction func spin(_ sender: UIButton) {
        switch (!restaurants.isEmpty, restaurantSlotMachine.isHidden) {
        case (true, true):
            // Initial stage
            slotMachineRoll()
        case (true, false):
            // slot machine already displayed. Should not allow user to spin again?
            let slotMachineShut = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.restaurantSlotMachine.isHidden = true
            }
            slotMachineShut.addCompletion { (_) in
                self.slotMachineRoll()
            }
            slotMachineShut.startAnimation()
        case (false, true):
            // data is not generated, did not think of a use case that this could happen.
            self.alertFor(type: .unhandledError, actions: nil)
        case (false, false):
            // data is not generated, but in initial stage, should be a network error
            self.alertFor(type: .unhandledError, actions: nil)
        }
    }
    
    func slotMachineRoll() {
        restaurants.shuffle()
        restaurantSlotMachine.reloadAllComponents()
        let selection = Int.random(in: 0 ..< restaurants.endIndex * repeats)
        let slotMachineDisplay = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.restaurantSlotMachine.isHidden = false
        }
        slotMachineDisplay.addCompletion { (_) in
            self.restaurantSlotMachine.selectRow(selection, inComponent: 0, animated: true)
            print(selection, self.restaurants.count)
            self.result = self.restaurants[selection % self.restaurants.count]
            self.showLabel.isHidden = false
        }
        slotMachineDisplay.startAnimation()
        spinCount += 1
        if spinCount >= 3 {
            self.spinLabel.isEnabled = false
            stypleDisabledButton()
            // pop a message here
        }
    }
    
}

// MARK: - Navigation: Present Details Card
extension DecideViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailCard = segue.destination as? DetailCardViewController else { return }
        guard let restaurant = self.result else { return }
        detailCard.restaurant = restaurant
    }
}

// MARK: Slot Machine!!
// REF: More rows: https://stackoverflow.com/questions/46206920/swift-making-a-uipickerview-go-round-as-a-loop
extension DecideViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeats * restaurants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.restaurants[row % restaurants.count].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentIndex = row % restaurants.count
        restaurantSlotMachine.selectRow((repeats / 2) * restaurants.count + currentIndex, inComponent: 0, animated: false)
    }
    
}

// MARK: - Customize Button look
extension DecideViewController {
    
    func styleSpinButton() {
        spinLabel.titleLabel?.layer.cornerRadius = 10
        spinLabel.titleLabel?.clipsToBounds = true
        spinLabel.titleLabel?.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.9215686275, blue: 0.6941176471, alpha: 1)
        
        self.spinLabel.setTitle("Only 3 Spins Allowed.", for: .disabled)
    }
    
    func stypleDisabledButton() {
        spinLabel.titleLabel?.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
}
