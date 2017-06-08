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

class EditMedicationViewController: UIViewController, UITextFieldDelegate
{
    //MARK: Properties
    var medicationBuilder: MedicationBuilder?
    var medicationThing: MHVThing?
    
    //MARK: UI Properties
    @IBOutlet weak var nameField: UIAutocompleteTextField!
    @IBOutlet weak var strengthAmountField: UIMedicationTextField!
    @IBOutlet weak var strengthUnitField: UIPickerTextField!
    @IBOutlet weak var doseAmountField: UIMedicationTextField!
    @IBOutlet weak var doseUnitField: UIPickerTextField!
    @IBOutlet weak var howOftenField: UIMedicationTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var strengthAmountErrorLabel: UILabel!
    @IBOutlet weak var strengthUnitErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    @IBOutlet weak var doseUnitErrorLabel: UILabel!
    @IBOutlet weak var howOftenErrorLabel: UILabel!
    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, medication: MHVThing,
         builder: MedicationBuilder)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.medicationThing = medication
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
        strengthUnitField.setup(pickerData: HVUnitTypes.strengthUnits)
        
        // Set error lables where needed
        nameField.errorLabel = medicationErrorLabel
        strengthAmountField.errorLabel = strengthAmountErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
        
        fillTextFieldsWithStoredValues()
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
                .begin(mhvThing: medicationThing!)
                .setName(name: nameField.text!)
                .setStrengthIfNotNil(amount: strengthAmountField.text!, unit: strengthUnitField.text!)
                .setDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
                .setFrequencyIfNotNil(frequency: howOftenField.text!)
                .constructMedication()
            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
            connection.thingClient()?.update(medication, record: connection.personInfo!.selectedRecordID, completion:
                {
                    (error: Error?) in
                })
        }
    }
    
    // MARK: Helper Functions
    func fillTextFieldsWithStoredValues()
    {
        guard let med = medicationThing!.medication() else
        {
            return
        }
        
        //Display Name
        if let name = med.name
        {
            nameField.text = name.text
        }
        
        //Display Dose
        if let dose = med.dose
        {
            if let doseMeasure = dose.measurement
            {
                doseAmountField.text = String(doseMeasure.value)
                doseUnitField.text = doseMeasure.units.text
            }
            else
            {
                doseUnitField.text = dose.displayText
            }
            if let index = doseUnitField.pickerData.index(of: doseUnitField.text!)
            {
                doseUnitField.picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        //Display Strength
        if let strength = med.strength
        {
            if let strengthMeasure = strength.measurement
            {
                strengthAmountField.text = String(strengthMeasure.value)
                strengthUnitField.text = strengthMeasure.units.text
            }
            else
            {
                strengthUnitField.text = strength.displayText
            }
            if let index = strengthUnitField.pickerData.index(of: strengthUnitField.text!)
            {
                strengthUnitField.picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        //Dispaly Frequency
        if let freq = med.frequency
        {
            howOftenField.text = freq.displayText
        }
    }
    
}
