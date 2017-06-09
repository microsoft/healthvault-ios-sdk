//
//  MedicationTextFieldTests.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/9/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

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
