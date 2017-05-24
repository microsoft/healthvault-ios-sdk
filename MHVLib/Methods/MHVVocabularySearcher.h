//
// MHVVocabularySearcher.h
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
//
#import <Foundation/Foundation.h>
#import "MHVVocabulary.h"
#import "MHVVocabularySearchTask.h"

@class MHVVocabularySearcher;

@protocol MHVVocabularySearcherDelegate <NSObject>

- (void)resultsAvailable:(MHVVocabularyCodeSet *)results forSearch:(NSString *)searchText inSearcher:(MHVVocabularySearcher *)searcher
               seqNumber:(NSUInteger)seq;

- (void)searchFailedFor:(NSString *)search inSearcher:(MHVVocabularySearcher *)searcher seqNumber:(NSUInteger)seq;

@end

@interface MHVVocabularySearchCache : NSObject

@property (readonly, nonatomic) NSCache *cache;
@property (readwrite, nonatomic) NSUInteger maxCachedResults;

- (instancetype)init;
- (instancetype)initWithCache:(NSCache *)cache;

//
// All searches are case IN-SENSITIVE
//
- (BOOL)hasCachedResultsForSearch:(NSString *)searchText;

- (MHVVocabularyCodeSet *)getResultsForSearch:(NSString *)searchText;
- (void)cacheResults:(MHVVocabularyCodeSet *)results forSearch:(NSString *)searchText;
- (void)removeCachedResultsForSearch:(NSString *)searchText;

- (void)ensureDummyEntryForSearch:(NSString *)searchText;

- (NSString *)normalizeSearchText:(NSString *)searchText;

@end

//
// You use this for your AutoComplete data sources
// 1. Searches a specified vocabulary
// 2. Maintains an internal cache to reduce roundtrips
// 3. All completions in UI thread
//
@interface MHVVocabularySearcher : NSObject

@property (readwrite, nonatomic, strong) MHVVocabularyIdentifier *vocab;
@property (readwrite, nonatomic) MHVVocabularyMatchType matchType;
@property (readwrite, nonatomic) int maxResults;
//
// Search cache.
// Readwrite - you can potentially share caches, or hold onto them
//
@property (readwrite, nonatomic, strong) MHVVocabularySearchCache *cache;
//
// DELEGATE
// Weak reference
//
@property (readwrite, nonatomic, weak) id<MHVVocabularySearcherDelegate> delegate;

- (instancetype)initWithVocab:(MHVVocabularyIdentifier *)vocab;
- (instancetype)initWithVocab:(MHVVocabularyIdentifier *)vocab andMaxResults:(int)max;

- (MHVVocabularySearchTask *)searchFor:(NSString *)text;

@end
