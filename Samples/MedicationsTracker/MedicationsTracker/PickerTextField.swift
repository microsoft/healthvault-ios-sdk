//
//  PickerTextField.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/7/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class PickerTextField: MedicationTextField, UIPickerViewDelegate, UIPickerViewDataSource
{
    // MARK: Properties
    private(set) var pickerData = [String]()
    private var pickerHasBeenCalled = false
    var picker = UIPickerView()
    
    
    func setup(pickerData: [String])
    {
        if !pickerHasBeenCalled
        {
            self.pickerData = pickerData
            self.picker.dataSource = self
            self.picker.delegate = self
            self.inputView = picker
            self.pickerHasBeenCalled = true;
        }
    }
    
    // MARK: UIPickerView Delegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return pickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.text = pickerData[row]
    }
}
