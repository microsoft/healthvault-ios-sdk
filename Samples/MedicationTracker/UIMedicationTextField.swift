//
//  TextFieldExtension.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 6/1/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import Foundation

class UIMedicationTextField: UITextField{
    
    var errorLabel: UILabel?
    
    func isEmpty() -> Bool {
        self.layer.borderWidth = 1.0
        if self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            self.layer.borderColor = UIColor.red.cgColor
            errorLabel?.isHidden = false
            return true
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
            errorLabel?.isHidden = true
            return false
        }
    }
    
    func isNumeric() -> Bool {
        self.layer.borderWidth = 1.0
        let scanner = Scanner(string: self.text!)
        scanner.locale = Locale.current
        // Set red outline if the text is not empty and not a number
        if !(scanner.scanDecimal(nil) && scanner.isAtEnd){
            if !(self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
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
