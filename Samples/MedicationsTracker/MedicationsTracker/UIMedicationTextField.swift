//
//  TextFieldExtension.swift
//  MedicationTracker
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


import Foundation

class UIMedicationTextField: UITextField
{
    
    var errorLabel: UILabel?
    
    func isEmpty() -> Bool
    {
        self.layer.borderWidth = 1.0
        if self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        {
            self.layer.borderColor = UIColor.red.cgColor
            errorLabel?.isHidden = false
            return true
        }
        else
        {
            self.layer.borderColor = UIColor.clear.cgColor
            errorLabel?.isHidden = true
            return false
        }
    }
    
    func isNumeric() -> Bool
    {
        self.layer.borderWidth = 1.0
        let scanner = Scanner(string: self.text!)
        scanner.locale = Locale.current
        // Set red outline if the text is not empty and not a number
        if !(scanner.scanDecimal(nil) && scanner.isAtEnd)
        {
            if !(self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
            {
                self.layer.borderColor = UIColor.red.cgColor
                errorLabel?.isHidden = false
                return false
            }
        }
        
        self.layer.borderColor = UIColor.clear.cgColor
        errorLabel?.isHidden = true
        return true
    }

}
