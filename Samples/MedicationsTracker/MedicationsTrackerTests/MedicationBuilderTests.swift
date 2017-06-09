//
//  MedicationBuilderTests.swift
//  MedicationsTracker
//
//  Created by Kayla Davis on 6/8/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import XCTest
@testable import MedicationsTracker

class MedicationBuilderTests: XCTestCase
{
    var builder: MedicationBuilder?
    
    override func setUp()
    {
        super.setUp()
        builder = MedicationBuilder().buildMedication(mhvThing: MHVMedication.newThing())
    }
    
    override func tearDown()
    {
        builder = nil
        super.tearDown()
    }
    
    // Name tests
    func testUpdateNameGivenString()
    {
        let med = "Advil"
        let didUpdate = builder?.updateNameIfNotNil(name: med)
        XCTAssertEqual(didUpdate, true, "Update should succeeded")
        XCTAssertEqual(builder?.med?.name.text, med, "The name should have been \(med)")
    }
    
    func testUpdateNameGivenEmptyString()
    {
        let didUpdate = builder?.updateNameIfNotNil(name: "")
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateNameGivenNil()
    {
        let didUpdate = builder?.updateNameIfNotNil(name: nil)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")

    }
    
    // Strength tests
    func testUpdateStrengthGivenAmountAndUnit()
    {
        let didUpdate = builder?.updateStrengthIfNotNil(amount: "500", unit: "mg")
        XCTAssertEqual(didUpdate, true, "Update should succeeded")
        XCTAssertEqual(builder?.med?.strength.displayText, "500 mg", "The strength should have been '500 mg'")
    }
    
    func testUpdateStrengthGivenAmountAndNilUnit()
    {
        let amount = "100"
        let unit: String? = nil
        let didUpdate = builder?.updateStrengthIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateStrengthGivenAmountAndEmptyUnit()
    {
        let amount = "100"
        let unit = ""
        let didUpdate = builder?.updateStrengthIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateStrengthGivenNilUnitAndEmptyAmount()
    {
        let amount = ""
        let unit: String? = nil
        
        let didUpdate = builder?.updateStrengthIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateStrengthGivenNonDoubleAmount()
    {
        let amount = "abc"
        let unit = "ml"
        let didUpdate = builder?.updateStrengthIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    // Dose test
    func testUpdateDoseGivenAmountAndUnit()
    {
        let didUpdate = builder?.updateDoseIfNotNil(amount: "2", unit: "Tablets")
        XCTAssertEqual(didUpdate, true, "Update should succeeded")
        XCTAssertEqual(builder?.med?.dose.displayText, "2 Tablets", "The dose should have been '2 Tablets'")
    }
    
    func testUpdateDoseGivenAmountAndNilUnit()
    {
        let amount = "100"
        let unit: String? = nil
        let didUpdate = builder?.updateDoseIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateDoseGivenAmountAndEmptyUnit()
    {
        let amount = "5"
        let unit = ""
        let didUpdate = builder?.updateDoseIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateDoseGivenNilUnitAndEmptyAmount()
    {
        let amount = ""
        let unit: String? = nil
        
        let didUpdate = builder?.updateDoseIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateDoseGivenNonDoubleAmount()
    {
        let amount = "abc"
        let unit = "Tablets"
        let didUpdate = builder?.updateDoseIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    // Freq test
    func testUpdateFrequencyGivenAmountAndUnit()
    {
        let didUpdate = builder?.updateFrequencyIfNotNil(amount: "2", unit: "times per week")
        XCTAssertEqual(didUpdate, true, "Update should succeeded")
        XCTAssertEqual(builder?.med?.frequency.displayText, "2 times per week", "The freq should have been '2 times per week'")
    }
    
    func testUpdateFrequencyGivenAmountAndNilUnit()
    {
        let amount = "100"
        let unit: String? = nil
        let didUpdate = builder?.updateFrequencyIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateFrequencyGivenAmountAndEmptyUnit()
    {
        let amount = "5"
        let unit = ""
        let didUpdate = builder?.updateFrequencyIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateFrequencyGivenNilUnitAndEmptyAmount()
    {
        let amount = ""
        let unit: String? = nil
        
        let didUpdate = builder?.updateFrequencyIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testUpdateFrequencyGivenNonDoubleAmount()
    {
        let amount = "xyz"
        let unit = "times a day"
        let didUpdate = builder?.updateFrequencyIfNotNil(amount: amount, unit: unit)
        XCTAssertEqual(didUpdate, false, "Update should have failed to update and returned false")
    }
    
    func testConstructMedication()
    {
        let constructedThing = builder?.constructMedication()
        
        XCTAssertTrue(constructedThing! === builder?.thing!)

    }

    
}
