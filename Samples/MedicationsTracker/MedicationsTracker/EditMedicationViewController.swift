//
//  AddMedicationViewController.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/30/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class EditMedicationViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    var medicationBuilder: MedicationBuilder?
    var medicationThing: MHVThing?
    let dosePicker = UIPickerView()
    let strengthPicker = UIPickerView()
    var strengthPickerData = HVUnitTypes.strengthUnits
    var dosePickerData = HVUnitTypes.doseUnits
    var autoComplete: MHVVocabularyCodeItemCollection?
    var searcher: MedicationVocabSearcher?


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
    @IBOutlet weak var nameTableView: UITableView!
    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, medication: MHVThing, builder: MedicationBuilder, searcher: MedicationVocabSearcher) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        medicationThing = medication
        medicationBuilder = builder
        self.searcher = searcher
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
        nameTableView.delegate = self
        nameTableView.dataSource = self
        nameTableView.isScrollEnabled = true
        nameTableView.isHidden = true
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if substring.characters.count >= searcher!.minSearchSize {
            nameTableView.isHidden = false
            searcher?.searchForMeds(searchValue: substring, completion: {autocompleteContents in
                DispatchQueue.main.async {
                    self.autoComplete = autocompleteContents
                }
            })
            nameTableView.reloadData()
        } else{
            nameTableView.isHidden = true
        }
        
        return true
    }
    
    // MARK UITableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel!.text = autoComplete![UInt(indexPath.row)].displayText
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.autoComplete != nil {
            return Int(self.autoComplete!.count())
        } else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        nameField.text = selectedCell.textLabel!.text!
        nameTableView.isHidden = true
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
