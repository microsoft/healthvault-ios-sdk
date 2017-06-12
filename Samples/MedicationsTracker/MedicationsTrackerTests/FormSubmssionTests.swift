//
//  FormSubmssionTests.swift
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

class FormSubmssionTests: XCTestCase
{
    var goodViews: [UIView]?
    var someNotValidViews: [UIView]?
    
    override func setUp()
    {
        super.setUp()
        let noRequired = MedicationTextField()
        let autoNoRequired = AutocompleteTextField()
        let needsToBeNumericGood = MedicationTextField()
        let needsToBeNumericBad = MedicationTextField()
        
        needsToBeNumericGood.shouldBeNumeric = true
        needsToBeNumericGood.text = "5"
        needsToBeNumericBad.shouldBeNumeric = true
        needsToBeNumericBad.text = "abc"
        
        goodViews = [noRequired, autoNoRequired, needsToBeNumericGood, UIView()]
        someNotValidViews = [noRequired, autoNoRequired, needsToBeNumericBad]
    }
    
    override func tearDown()
    {
        goodViews = nil
        someNotValidViews = nil
        super.tearDown()
    }
    
    func testCanSubmitGivenMedicationTextWithValidData()
    {
        let canSubmit = FormSubmission.canSubmit(subviews: goodViews!)
        XCTAssertEqual(canSubmit, true, "All of the views should be valid")
    }
    
    func testCanSubmitGivenMedicationTextWithInvalidData()
    {
        let canSubmit = FormSubmission.canSubmit(subviews: someNotValidViews!)
        XCTAssertEqual(canSubmit, false, "One of the views should have been invalid")
    }
    
}
