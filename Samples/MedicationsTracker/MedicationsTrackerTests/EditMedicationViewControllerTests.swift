//
//  EditMedicationViewControllerTests.swift
//  MedicationsTracker
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

import XCTest
@testable import MedicationsTracker

class EditMedicationViewControllerTests: XCTestCase
{
    var editViewController : EditMedicationViewController?
    var medField: MedicationTextField?
    var pickerField: PickerTextField?
    var nameField: MedicationTextField?
    var medThing: MHVThing? = nil
    
    override func setUp()
    {
        super.setUp()
        
        medThing = MHVMedication.newThing()
        let med = medThing?.medication()
        med?.strength = MHVApproxMeasurement.fromValue(500, unitsText: "Milligrams (mg)",
                                       unitsCode: "Milligrams (mg)", unitsVocab: "medication-strength-unit")
        med?.dose = MHVApproxMeasurement.fromDisplayText("A single tablet")
        editViewController = EditMedicationViewController.init(nibName: "EditMedicationViewController", bundle: nil,
                                                              medication: medThing!,
                                                              builder: MedicationBuilder())
        med?.name = MHVCodableValue.fromText("Advil")
        editViewController?.nameField = AutocompleteTextField()
        editViewController?.strengthAmountField = MedicationTextField()
        editViewController?.strengthUnitField = PickerTextField()
        editViewController?.doseAmountField = MedicationTextField()
        editViewController?.doseUnitField = PickerTextField()
        
        medField = MedicationTextField()
        pickerField = PickerTextField()
    }
    
    override func tearDown()
    {
        editViewController = nil
        medThing = nil
        super.tearDown()
    }
    
    func testFillFieldsWithPickersGivenHasMeasurement()
    {
        editViewController!.fillFieldsWithPickers(approxMeasure: medThing!.medication().strength,
                                                 amountField: medField!, unitField: pickerField!)
        
        XCTAssertEqual(medField!.text, "500", "Amount was initalized as 500, so the medField text should be '500'")
        XCTAssertEqual(pickerField!.text, "Milligrams (mg)", "Amount should be initalized as 'Milligrams (mg)'")

    }
    
    func testFillFieldsWithPickersGivenNoMeasurement()
    {
        editViewController!.fillFieldsWithPickers(approxMeasure: medThing!.medication().dose,
                                                 amountField: medField!, unitField: pickerField!)
        XCTAssertEqual(pickerField!.text, "A single tablet", "Unit should be initalized as 'A single tablet'")
    }
    
    func testfillTextFieldsWithStoredValues()
    {
        editViewController!.fillTextFieldsWithStoredValues()
        XCTAssertEqual(editViewController!.nameField.text!, "Advil", "Text should be set as 'Advil'")
    }
    
}
