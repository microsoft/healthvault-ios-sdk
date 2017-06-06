//
//  MedicationBuilder.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 5/31/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import Foundation

class MedicationBuilder {
    var thing: MHVThing?
    var med: MHVMedication?
    
    func begin(mhvThing: MHVThing) -> MedicationBuilder{
        thing = mhvThing
        med = mhvThing.medication()
        return self
    }
    
    func setName(name: String) -> MedicationBuilder {
        med!.name = MHVCodableValue.fromText(name)
        return self
    }
    
    func setStrengthIfNotNil(amount: String, unit: String?) -> MedicationBuilder {
        guard let strengthAmount = Double(amount), let strengthUnit = unit else {
            return self
        }
        med!.strength = MHVApproxMeasurement.fromValue(strengthAmount, unitsText: strengthUnit, unitsCode: strengthUnit, unitsVocab: "medication-strength-unit")
        return self
    }
    
    func setDoseIfNotNil(amount: String, unit: String?) -> MedicationBuilder {
        guard let doseAmount = Double(amount), let doseUnit = unit else{
            return self
        }
        med!.dose = MHVApproxMeasurement.fromValue(doseAmount, unitsText: doseUnit, unitsCode: doseUnit, unitsVocab: "medication-dose-units")
        return self
    }
    
    func setFrequencyIfNotNil(frequency: String?) -> MedicationBuilder {
        guard let freq = frequency else{
            return self
        }
        med!.frequency = MHVApproxMeasurement.fromDisplayText(freq)
        return self
    }
    
    func constructMedication() -> MHVThing {
        return thing!
    }
}
