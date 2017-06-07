//
//  PickerContentCreator.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 6/5/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import Foundation

struct HVUnitTypes {
    static let doseUnits = ["Applicatorfuls","Bags", "Bars","Capsules", "Doses", "Dropperfuls",
                     "Drops", "Grams (g)", "Inhalations", "Lozenges","Micrograms (mcg)",
                     "Milligrams (mg)","Milliliters (ml)","Packets", "Pads", "Patches",
                     "Percent (%)", "Puffs", "Scoops", "Shots", "Sprays","Suppositories",
                     "Syringe","Tablespoons (tbsp)", "Tablets", "Teaspoons (tsp)", "Units (U)"]
    static let strengthUnits = ["Colony forming units per milliliter (cfu/ml)", "International unit (iu)",
                         "Micrograms (mcg)", "Milliequivalent (meq)", "Milliequivalent per milliliter (meq/ml)",
                         "Milligram (mg)","Milligram per milliliter (mg/ml)", "Milliliter (ml)", "Percent (%)",
                         "Unit (unt)","Units per milliliter (unt/ml)"]
}

class MedicationVocabSearcher {
    let minSearchSize = 3

    func searchForMeds(searchValue: String, completion: @escaping(MHVVocabularyCodeItemCollection?) -> Void){
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        let key = MHVVocabularyKey.init(name: "RxNorm Active Medicines", andFamily: "RxNorm", andVersion: "09AB_091102F", andCode: nil)
        connection.vocabularyClient()?.searchVocabulary(withSearchValue: searchValue, searchMode: MHVSearchMode.contains, vocabularyKey: key!, maxResults: 25, completion: { (matchedMeds: MHVVocabularyCodeSetCollection?, error: Error?) in
            let meds = matchedMeds!.firstObject().vocabularyCodeItems
            completion(meds)
        })
    }
}


