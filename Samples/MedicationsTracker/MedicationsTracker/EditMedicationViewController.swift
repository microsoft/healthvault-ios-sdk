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
    @IBOutlet weak var nameField: AutocompleteTextField!
    @IBOutlet weak var strengthAmountField: MedicationTextField!
    @IBOutlet weak var strengthUnitField: PickerTextField!
    @IBOutlet weak var doseAmountField: MedicationTextField!
    @IBOutlet weak var doseUnitField: PickerTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var strengthAmountErrorLabel: UILabel!
    @IBOutlet weak var strengthUnitErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    @IBOutlet weak var doseUnitErrorLabel: UILabel!
    @IBOutlet weak var freqAmountErrorLabel: UILabel!
    @IBOutlet weak var freqUnitErrorLabel: UILabel!
    @IBOutlet weak var freqAmountField: PickerTextField!
    @IBOutlet weak var freqUnitField: PickerTextField!

    
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
        
        // Set error labels where needed
        nameField.errorLabel = medicationErrorLabel
        strengthAmountField.errorLabel = strengthAmountErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
        
        fillTextFieldsWithStoredValues()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Setup custom field types
        nameField.setup()
        doseUnitField.setup(pickerData: HVUnitTypes.doseUnits)
        strengthUnitField.setup(pickerData: HVUnitTypes.strengthUnits)
        freqAmountField.setup(pickerData: HVUnitTypes.freqAmount)
        freqUnitField.setup(pickerData: HVUnitTypes.freqUnit)
        
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
        let text = textField as! MedicationTextField
        _ = text.isValid()
        
        return true
    }
    
    // MARK: Actions
    @IBAction func addMedication(_ sender: UIButton)
    {
        if(FormSubmission.canSubmit(subviews: self.view.subviews))
        {
            let medToConstruct = medicationBuilder?.buildMedication(mhvThing: medicationThing!)
            _ = medToConstruct?.updateNameIfNotNil(name: nameField.text!)
            _ = medToConstruct?.updateDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
            _ = medToConstruct?.updateStrengthIfNotNil(amount: strengthAmountField.text!, unit: strengthUnitField.text!)
            _ = medToConstruct?.updateFrequencyIfNotNil(amount: freqAmountField.text!, unit: freqUnitField.text!)
            
            let medication = medToConstruct?.constructMedication()

            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
            connection.thingClient()?.update(medication!, record: connection.personInfo!.selectedRecordID, completion:
                {
                    (error: Error?) in
                })
        }
    }
    
    // MARK: Helper Functions

    func fillFieldsWithPickers(approxMeasure: MHVApproxMeasurement, amountField: MedicationTextField,
                          unitField: PickerTextField)
    {
        // Set values if it has a measurement or just show display text
        if let theMeasure = approxMeasure.measurement
        {
            let amount = NumberFormatter.localizedString(from: NSNumber(value: theMeasure.value),
                                                      number: NumberFormatter.Style.decimal)
            amountField.text = amount
            unitField.text = theMeasure.units.text
        }
        else
        {
            unitField.text = approxMeasure.displayText
        }
        
        // Set picker rows to selected text
        if let index = unitField.pickerData.index(of: unitField.text!)
        {
            unitField.picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        if let amountPickerField = amountField as? PickerTextField
        {
            if let index = amountPickerField.pickerData.index(of: amountPickerField.text!)
            {
                amountPickerField.picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
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
            fillFieldsWithPickers(approxMeasure: dose, amountField: doseAmountField, unitField: doseUnitField)
        }
        
        //Display Strength
        if let strength = med.strength
        {
            fillFieldsWithPickers(approxMeasure: strength, amountField: strengthAmountField, unitField: strengthUnitField)
        }
        
        //Dispaly Frequency
        if let freq = med.frequency
        {
            fillFieldsWithPickers(approxMeasure: freq, amountField: freqAmountField, unitField: freqUnitField)
        }
    }
    
}
