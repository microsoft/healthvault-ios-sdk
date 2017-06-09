//
//  HVUnitTypes.swift
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

import Foundation

struct HVUnitTypes
{
    static let doseUnits = ["Applicatorfuls","Bags", "Bars","Capsules", "Doses", "Dropperfuls",
                            "Drops", "Grams (g)", "Inhalations", "Lozenges","Micrograms (mcg)",
                            "Milligrams (mg)","Milliliters (ml)","Packets", "Pads", "Patches",
                            "Percent (%)", "Puffs", "Scoops", "Shots", "Sprays","Suppositories",
                            "Syringe","Tablespoons (tbsp)", "Tablets", "Teaspoons (tsp)", "Units (U)"]
    
    static let strengthUnits = ["Colony forming units per milliliter (cfu/ml)", "International unit (iu)",
                                "Micrograms (mcg)", "Milliequivalent (meq)", "Milliequivalent per milliliter (meq/ml)",
                                "Milligram (mg)","Milligram per milliliter (mg/ml)", "Milliliter (ml)", "Percent (%)",
                                "Unit (unt)","Units per milliliter (unt/ml)"]
    
    static let freqAmount = ["1", "2", "3", "4", "5", "6", "7"]
    
    static let freqUnit = ["times per day", "times per week", "times per month"]
}
