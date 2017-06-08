//
//  AddMedicationViewController.swift
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

import UIKit

class AddMedicationViewController: UIViewController, UITextFieldDelegate
{
    
    //MARK: Properties
    var medicationBuilder: MedicationBuilder?
    
    //MARK: UI Properties
    @IBOutlet weak var nameField: UIAutocompleteTextField!
    @IBOutlet weak var doseAmountField: UIMedicationTextField!
    @IBOutlet weak var doseUnitField: UIPickerTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, builder: MedicationBuilder)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.medicationBuilder = builder
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup custom field types
        nameField.setup()
        doseUnitField.setup(pickerData: HVUnitTypes.doseUnits)
        
        // Set error lables where needed
        nameField.errorLabel = medicationErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
    }
    
    // MARK: UITextField Delegation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        // Highlight cells that are invalid, but ignore returned value
        let text = textField as! UIMedicationTextField
        _ = text.isValid()
        
        // Hide autocomplete table when done editing
        nameField.tableView?.isHidden = true
        
        return true
    }
    
    // MARK: Actions
    @IBAction func addMedication(_ sender: UIButton)
    {
        if(FormSubmission.canSubmit(subviews: self.view.subviews))
        {
            let medication = medicationBuilder!
                .begin(mhvThing: MHVMedication.newThing())
                .setName(name: nameField.text!)
                .setDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
                .constructMedication()
            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(
                with: HVFeaturesConfiguration.configuration())
            connection.thingClient()?.createNewThing(
                medication, record: connection.personInfo!.selectedRecordID, completion:
                {
                    (error: Error?) in
                })
        }
    }
}
