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

class AddMedicationViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource,
    UITableViewDelegate, UITableViewDataSource
{
    
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
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         builder: MedicationBuilder, searcher: MedicationVocabSearcher)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        medicationBuilder = builder
        self.searcher = searcher
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        doseUnitField.inputView = dosePicker
        dosePicker.delegate = self
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
        nameTableView.isHidden = true
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool
    {
         searcher?.showMedList(textField: textField, nameTableView: nameTableView,
                                                  range: range, string: string, completion:
            {
                autocompleteContents in
                self.autoComplete = autocompleteContents
                
            })
        return true
    }
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Int(dosePickerData.count)
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return dosePickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        doseUnitField.text = dosePickerData[row]
    }
    
    // MARK UITableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel!.text = autoComplete![UInt(indexPath.row)].displayText
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.autoComplete != nil
        {
            return Int(self.autoComplete!.count())
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        nameField.text = selectedCell.textLabel!.text!
        nameTableView.isHidden = true
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
