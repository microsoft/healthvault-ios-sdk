//
//  MedicationBuilder.swift
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


import Foundation

class MedicationBuilder {
    
    // MARK: Properties
    private var thing: MHVThing?
    private var med: MHVMedication?
    
    // MARK: Builder functions
    func buildMedication(mhvThing: MHVThing) -> MedicationBuilder
    {
        thing = mhvThing
        med = mhvThing.medication()
        return self
    }
    
    func updateNameIfNotNil(name: String?) -> Bool
    {
        guard let medName = name else
        {
            return false
        }
        
        med!.name = MHVCodableValue.fromText(medName)
        return true
    }
    
    func updateStrengthIfNotNil(amount: String, unit: String?) -> Bool
    {
        guard let strengthAmount = Double(amount), let strengthUnit = unit else
        {
            return false
        }
        med!.strength = MHVApproxMeasurement.fromValue(strengthAmount, unitsText: strengthUnit,
                                                       unitsCode: strengthUnit, unitsVocab: "medication-strength-unit")
        return true
    }
    
    func updateDoseIfNotNil(amount: String, unit: String?) -> Bool
    {
        guard let doseAmount = Double(amount), let doseUnit = unit else
        {
            return false
        }
        med!.dose = MHVApproxMeasurement.fromValue(doseAmount, unitsText: doseUnit,
                                                   unitsCode: doseUnit, unitsVocab: "medication-dose-units")
        return true
    }
    
    func updateFrequencyIfNotNil(frequency: String?) -> Bool
    {
        guard let freq = frequency else
        {
            return false
        }
        med!.frequency = MHVApproxMeasurement.fromDisplayText(freq)
        return true
    }
    
    func constructMedication() -> MHVThing
    {
        return thing!
    }
}
