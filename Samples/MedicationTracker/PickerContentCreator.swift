//
//  PickerContentCreator.swift
//  MedicationTracker
//
//  Created by Kayla Davis on 6/5/17.
//  Copyright © 2017 Kayla Davis. All rights reserved.
//

import Foundation

class MedicationVocabSearcher {
    func createContentWithVocab(name: String, family: String, version: String, completion: @escaping([String]) -> Void) {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        let doseKey = MHVVocabularyKey.init(name: name, andFamily: family, andVersion: version, andCode: nil)
        var pickerData = [String]()
        connection.vocabularyClient()?.getVocabularyWith(doseKey!, cultureIsFixed: false, completion: { (doseTypes:MHVVocabularyCodeSet?, error:Error?) in
            doseTypes?.displayStrings().forEach{doseType in
                pickerData.append(String(describing: doseType))}
            completion(pickerData)
        })
    }
}
