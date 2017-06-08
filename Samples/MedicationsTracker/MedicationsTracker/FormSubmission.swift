//
//  FormSubmission.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/8/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import Foundation

struct FormSubmission
{
    static func canSubmit(subviews: [UIView]) -> Bool
    {
        var fieldsComplete = true
        for subview in subviews
        {
            if let textField = subview as? UIMedicationTextField
            {
                if !textField.isValid()
                {
                    fieldsComplete = false
                }
            }
        }
        return fieldsComplete
    }
    
}
