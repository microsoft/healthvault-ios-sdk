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
    var thing: MHVThing?
    var med: MHVMedication?
    
    func begin(mhvThing: MHVThing) -> MedicationBuilder
    {
        thing = mhvThing
        med = mhvThing.medication()
        return self
    }
    
    func setName(name: String) -> MedicationBuilder
    {
        med!.name = MHVCodableValue.fromText(name)
        return self
    }
    
    func setStrengthIfNotNil(amount: String, unit: String?) -> MedicationBuilder
    {
        guard let strengthAmount = Double(amount), let strengthUnit = unit else
        {
            return self
        }
        med!.strength = MHVApproxMeasurement.fromValue(strengthAmount, unitsText: strengthUnit,
                                                       unitsCode: strengthUnit, unitsVocab: "medication-strength-unit")
        return self
    }
    
    func setDoseIfNotNil(amount: String, unit: String?) -> MedicationBuilder
    {
        guard let doseAmount = Double(amount), let doseUnit = unit else
        {
            return self
        }
        med!.dose = MHVApproxMeasurement.fromValue(doseAmount, unitsText: doseUnit,
                                                   unitsCode: doseUnit, unitsVocab: "medication-dose-units")
        return self
    }
    
    func setFrequencyIfNotNil(frequency: String?) -> MedicationBuilder
    {
        guard let freq = frequency else
        {
            return self
        }
        med!.frequency = MHVApproxMeasurement.fromDisplayText(freq)
        return self
    }
    
    func constructMedication() -> MHVThing
    {
        return thing!
    }
}
