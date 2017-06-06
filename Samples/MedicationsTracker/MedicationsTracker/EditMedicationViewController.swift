//
//  AddMedicationViewController.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/30/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class EditMedicationViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Properties
    var medicationBuilder: MedicationBuilder?
    var medicationThing: MHVThing?
    let dosePicker = UIPickerView()
    let strengthPicker = UIPickerView()
    var strengthPickerData = [String]()
    var dosePickerData = [String]()
    
    //MARK: UI Properties
    @IBOutlet weak var nameField: UIMedicationTextField!
    @IBOutlet weak var strengthAmountField: UIMedicationTextField!
    @IBOutlet weak var strengthUnitField: UIMedicationTextField!
    @IBOutlet weak var doseAmountField: UIMedicationTextField!
    @IBOutlet weak var doseUnitField: UIMedicationTextField!
    @IBOutlet weak var howOftenField: UIMedicationTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var strengthAmountErrorLabel: UILabel!
    @IBOutlet weak var strengthUnitErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    @IBOutlet weak var doseUnitErrorLabel: UILabel!
    @IBOutlet weak var howOftenErrorLabel: UILabel!
    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, medication: MHVThing, builder: MedicationBuilder, searcher: MedicationVocabSearcher) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        medicationBuilder = builder
        medicationThing = medication
        searcher.createContentWithVocab(name: "medication-dose-units", family: "wc", version: "1"){ (pickerContents) in
            DispatchQueue.main.async {
                self.dosePickerData = pickerContents
            }
        }
        searcher.createContentWithVocab(name: "medication-strength-unit", family: "wc", version: "1"){ (pickerContents) in
            DispatchQueue.main.async {
                self.strengthPickerData = pickerContents
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doseUnitField.inputView = dosePicker
        strengthUnitField.inputView = strengthPicker
        dosePicker.delegate = self
        strengthPicker.delegate = self
        nameField.errorLabel = medicationErrorLabel
        strengthAmountField.errorLabel = strengthAmountErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
        fillTextFieldsWithStoredValues()
    }
    
    // MARK: UITextField Delegation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField as! UIMedicationTextField
        _ = text.isEmpty()
        if (textField == doseAmountField || textField == strengthAmountField){
        _ = text.isNumeric()
        }
        return true
    }
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == dosePicker {
            return dosePickerData.count
        } else {
            return strengthPickerData.count
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == dosePicker {
            return dosePickerData[row]
        } else {
            return strengthPickerData[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == dosePicker {
            doseUnitField.text = dosePickerData[row]
        } else {
            strengthUnitField.text = strengthPickerData[row]
        }
    }
    
    // MARK: Actions
    @IBAction func addMedication(_ sender: UIButton) {
        if(fieldsAreComplete()){
            let medication = medicationBuilder!
                .begin(mhvThing: medicationThing!)
                .setName(name: nameField.text!)
                .setStrengthIfNotNil(amount: strengthAmountField.text!, unit: strengthUnitField.text!)
                .setDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
                .setFrequencyIfNotNil(frequency: howOftenField.text!)
                .constructMedication()
            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
            connection.thingClient()?.update(medication, record: connection.personInfo!.selectedRecordID, completion: { (error: Error?) in
                print("editing med")
            })
        }
    }
    
    // MARK: Helper Functions
    func fieldsAreComplete() -> Bool {
        if(nameField.isEmpty() || !doseAmountField.isNumeric() || !strengthAmountField.isNumeric()){
            return false
        }
        return true
    }
    
    func fillTextFieldsWithStoredValues(){
        guard let med = medicationThing!.medication() else {
            return
        }
        
        //Display Name
        if let name = med.name{
            nameField.text = name.text
        }
        
        //Display Dose
        if let dose = med.dose{
            if let doseMeasure = dose.measurement{
                doseAmountField.text = String(doseMeasure.value)
                doseUnitField.text = doseMeasure.units.text
            } else{
                doseUnitField.text = dose.displayText
            }
            if let index = dosePickerData.index(of: doseUnitField.text!){
                dosePicker.selectRow(index, inComponent: 0, animated: false)
            }
        }

        //Display Strength
        if let strength = med.strength{
            if let strengthMeasure = strength.measurement{
                strengthAmountField.text = String(strengthMeasure.value)
                strengthUnitField.text = strengthMeasure.units.text
            } else{
                strengthUnitField.text = strength.displayText
            }
            if let index = strengthPickerData.index(of: strengthUnitField.text!){
                strengthPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        //Dispaly Frequency
        if let freq = med.frequency{
            howOftenField.text = freq.displayText
        }
    }
    
}
