//
//  MedicationTextFieldTests.swift
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

class MedicationTextFieldTests: XCTestCase
{
    var medField: MedicationTextField?
    override func setUp()
    {
        super.setUp()
        medField = MedicationTextField()
    }
    
    override func tearDown()
    {
        medField = nil
        super.tearDown()
    }
    
    func testIsNumericGivenNonNumericVal()
    {
        medField!.shouldBeNumeric = true
        medField!.text = "e"
        let isValid = medField!.isNumeric()
        XCTAssertEqual(isValid, false, "The text was marked as numeric when it shouldn't have been")
    }
    
    func testIsNumericGivenEmptyString()
    {
        medField!.shouldBeNumeric = true
        medField!.text = ""
        let isValid = medField!.isNumeric()
        XCTAssertEqual(isValid, true, "The text should have been marked as numeric, since an empty string is ok")
    }
    
    func testIsNumericGivenNumericVal()
    {
        medField!.shouldBeNumeric = true
        medField!.text = "481.5"
        let isValid = medField!.isNumeric()
        XCTAssertEqual(isValid, true, "The text should have been marked as numeric")
    }
    
    func testisEmptyGivenNonEmptyString()
    {
        medField!.shouldNotBeEmpty = true
        medField!.text = "a string"
        let isValid = medField!.isEmpty()
        XCTAssertEqual(isValid, false, "The text is not empty, so isEmpty should have return false")
    }
    
    func testisEmptyGivenEmptyString()
    {
        medField!.shouldNotBeEmpty = true
        medField!.text = ""
        let isValid = medField!.isEmpty()
        XCTAssertEqual(isValid, true, "The text is empty, so isEmpty should have return true")
    }
    
    func testIsValidGivenNoRequiredValues()
    {
        medField!.shouldNotBeEmpty = false
        medField!.shouldBeNumeric = false
        let isValid = medField!.isValid()
        XCTAssertEqual(isValid, true, "There are no required values so, isValid should return true")
    }
    
    func testIsValidWithRequiredAndGoodVals()
    {
        medField!.shouldNotBeEmpty = true
        medField!.shouldBeNumeric = true
        medField!.text = "45"
        let isValid = medField!.isValid()
        XCTAssertEqual(isValid, true, "The text '45' is numeric and non-empty so isValid should return true")
    }
    
    func testIsValidWithRequiredAndBadVals()
    {
        medField!.shouldNotBeEmpty = true
        medField!.shouldBeNumeric = true
        medField!.text = ""
        let isValid = medField!.isValid()
        XCTAssertEqual(isValid, false, "isValid should return false because one of it's required vals is not satisfied")
    }
}
