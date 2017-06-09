//
//  FormSubmssionTests.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/9/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

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
