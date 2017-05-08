//
//  MHVVocabularyClientProtocol.h
//  HVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#include "MHVVocabularyKey.h"

@class MHVVocabulary, MHVVocabulary, MHVVocabularySearchType;

@protocol MHVClientProtocol;

/**
 The protocol for HealthVault vocabulary clients
 */
@protocol MHVVocabularyClientProtocol <MHVClientProtocol>

/**
 Retrieves a collection of key information for identifying and describing the vocabularies in the system.

 @return An NSArray of all available MHVVocabularyKeys.
 */
-(NSArray * _Nonnull) GetVocabularyKeys;


/**
 Retrieves lists of vocabulary items for the specified vocabulary in the user's current culture.

 @param key The key for the vocabulary to fetch.
 @param cultureIsFixed Healthvault looks for the vocabulary items for the culture info specified by the system. If this parameter is set to NO or is not specified and if items are not found for the specified culture then items for the default fallback culture will be returned. If this parameter is set to YES then fallback will not occur.
 @return The matching MHVVocabulary
 */
-(MHVVocabulary * _Nonnull) GetVocabulary:(MHVVocabulary * _Nonnull) key
                  cultureIsFixed:(NSNumber * _Nullable) cultureIsFixed;


/**
 Retrieves lists of vocabulary items for the specified vocabularies in the user's current culture.

 @param vocabularyKeys An array of VocabularyKeys identifying the requested vocabularies.
 @param cultureIsFixed Healthvault looks for the vocabulary items for the culture info specified by the system. If this parameter is set to NO or is not specified and if items are not found for the specified culture then items for the default fallback culture will be returned. If this parameter is set to YES then fallback will not occur.
 @return One of the specified vocabularies and its items, or empty strings.
 */
-(NSArray * _Nonnull) GetVocabularies:(NSArray * _Nonnull) vocabularyKeys
                       cultureIsFixed:(NSNumber * _Nullable) cultureIsFixed;


/**
 Searches a specific vocabulary and retrieves the matching vocabulary items.

 @param searchValue The search string to use.
 @param searchType The type of search to perform.
 @param maxResults The maximum number of results to return. If null, all matching results are returned, up to a maximum number defined by the service config value with key maxResultsPerVocabularyRetrieval.
 @return An array of MHVVocabularyKeys populated with entries matching the search criteria.
 */
-(NSArray * _Nonnull) SearchVocabulary:(NSString * _Nonnull) searchValue
                            searchType:(MHVVocabularySearchType * _Nonnull) searchType
                            maxResults:(NSNumber * _Nullable) maxResults;

@end
