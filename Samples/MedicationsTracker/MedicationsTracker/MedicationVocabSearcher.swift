//
//  MedicationVocabSearcher.swift
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

class MedicationVocabSearcher
{
    let minSearchSize = 3

    func searchForMeds(searchValue: String, completion: @escaping(MHVVocabularyCodeItemCollection?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        let key = MHVVocabularyKey.init(name: "RxNorm Active Medicines", andFamily: "RxNorm",
                                        andVersion: "09AB_091102F", andCode: nil)
        
        //TODO: handle autocomplete suggestions coming in out of order
        connection.vocabularyClient()?.searchVocabulary(withSearchValue: searchValue,
                                                        searchMode: MHVSearchMode.contains, vocabularyKey: key!,
                                                        maxResults: 25, completion:
            {
                (matchedMeds: MHVVocabularyCodeSetCollection?, error: Error?) in
                let meds = matchedMeds!.firstObject().vocabularyCodeItems
                completion(meds)
            })
    }
}
