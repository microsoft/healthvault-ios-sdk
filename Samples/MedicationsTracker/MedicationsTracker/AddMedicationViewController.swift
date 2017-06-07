//
//  AddMedicationViewController.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 6/1/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import UIKit

class AddMedicationViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    var medicationBuilder: MedicationBuilder?
    let dosePicker = UIPickerView()
    var dosePickerData = HVUnitTypes.doseUnits
    var autoComplete: MHVVocabularyCodeItemCollection?
    var searcher: MedicationVocabSearcher?
    let minSearchSize = 3
    
    //MARK: UI Properties
    @IBOutlet weak var nameField: UIMedicationTextField!
    @IBOutlet weak var doseAmountField: UIMedicationTextField!
    @IBOutlet weak var doseUnitField: UIMedicationTextField!
    @IBOutlet weak var medicationErrorLabel: UILabel!
    @IBOutlet weak var doseAmountErrorLabel: UILabel!
    @IBOutlet weak var nameTableView: UITableView!

    
    //Mark: Initializers
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, builder: MedicationBuilder, searcher: MedicationVocabSearcher) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        medicationBuilder = builder
        self.searcher = searcher
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doseUnitField.inputView = dosePicker
        dosePicker.delegate = self
        nameField.errorLabel = medicationErrorLabel
        doseAmountField.errorLabel = doseAmountErrorLabel
        
        nameTableView.delegate = self
        nameTableView.dataSource = self
        nameTableView.isScrollEnabled = true
        nameTableView.isHidden = true
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
        if (textField == doseAmountField){
            _ = text.isNumeric()
        }
        nameTableView.isHidden = true

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if substring.characters.count >= minSearchSize {
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
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(dosePickerData.count)
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dosePickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        doseUnitField.text = dosePickerData[row]
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
    
    
    // MARK: Actions
    @IBAction func addMedication(_ sender: UIButton){
        if(fieldsAreComplete()){
            let medication = medicationBuilder!
                .begin(mhvThing: MHVMedication.newThing())
                .setName(name: nameField.text!)
                .setDoseIfNotNil(amount: doseAmountField.text!, unit: doseUnitField.text!)
                .constructMedication()
            let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
            connection.thingClient()?.createNewThing(medication, record: connection.personInfo!.selectedRecordID, completion: { (error: Error?) in
            })
        }
    }
    
    // MARK: Helper Functions
    func fieldsAreComplete() -> Bool {
        if(nameField.isEmpty() || !doseAmountField.isNumeric()){
            return false
        }
        return true
    }
}
