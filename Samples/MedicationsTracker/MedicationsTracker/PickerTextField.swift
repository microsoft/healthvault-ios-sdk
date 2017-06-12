//
//  PickerTextField.swift
//  MedicationsTracker
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
