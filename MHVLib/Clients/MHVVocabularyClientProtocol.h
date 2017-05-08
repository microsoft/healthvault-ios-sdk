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

@class MHVVocabulary, MHVVocabulary, MHVVocabularyKey, MHVVocabularySearchType;

@protocol MHVClientProtocol;

/**
 The protocol for HealthVault vocabulary clients
 */
@protocol MHVVocabularyClientProtocol <MHVClientProtocol>

/**
 Retrieves a collection of key information for identifying and describing the vocabularies in the system.

 @param completion A completion block. On success will give an NSArray of vocabulary keys. On error will give the error info.
 */
-(void) GetVocabularyKeysWithCompletion:(void(^_Nonnull)(NSArray<MHVVocabularyKey *> *_Nullable) vocabularyKeys, NSError *_Nullable error))completion;


/**
 Retrieves lists of vocabulary items for the specified vocabulary in the user's current culture.

 @param key The key for the vocabulary to fetch.
 @param cultureIsFixed Healthvault looks for the vocabulary items for the culture info specified by the system. If this parameter is set to NO or is not specified and if items are not found for the specified culture then items for the default fallback culture will be returned. If this parameter is set to YES then fallback will not occur.
 @param completion A completion block. On success will give the matching MHVVocabulary. On error will give the error info.
 */
-(void) GetVocabularyWithCompletion:(MHVVocabulary * _Nonnull) key
                     cultureIsFixed:(NSNumber * _Nullable) cultureIsFixed
                         completion:(void(^_Nonnull)(MHVVocabulary *_Nullable vocabulary, NSError *_Nullable error))completion;


/**
 Retrieves lists of vocabulary items for the specified vocabularies in the user's current culture.

 @param vocabularyKeys An array of VocabularyKeys identifying the requested vocabularies.
 @param cultureIsFixed Healthvault looks for the vocabulary items for the culture info specified by the system. If this parameter is set to NO or is not specified and if items are not found for the specified culture then items for the default fallback culture will be returned. If this parameter is set to YES then fallback will not occur.
 @param completion A completion block. On success will give one of the specified vocabularies and its items, or empty strings. On error will give the error info.
 */
-(void) GetVocabulariesWithCompletion:(NSArray * _Nonnull) vocabularyKeys
                       cultureIsFixed:(NSNumber * _Nullable) cultureIsFixed
                           completion:(void(^_Nonnull)(NSArray<MHVVocabulary *> *_Nullable vocabularies, NSError *_Nullable error))completion;


/**
 Searches a specific vocabulary and retrieves the matching vocabulary items.

 @param searchValue The search string to use.
 @param searchType The type of search to perform.
 @param maxResults The maximum number of results to return. If null, all matching results are returned, up to a maximum number defined by the service config value with key maxResultsPerVocabularyRetrieval.
 @param completion A completion block. On success will give an array of MHVVocabularyKeys populated with entries matching the search criteria. On error will give the error info.
 */
-(void) SearchVocabularyWithCompletion:(NSString * _Nonnull) searchValue
                            searchType:(MHVVocabularySearchType * _Nonnull) searchType
                            maxResults:(NSNumber * _Nullable) maxResults
                            completion:(void(^_Nonnull)(NSArray<MHVVocabularyKey *> *_Nullable vocabularyKeys, NSError *_Nullable error))completion;

@end
