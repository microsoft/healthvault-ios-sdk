//
//  MHVVocabSearcher.h
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
//
#import <Foundation/Foundation.h>
#import "MHVVocab.h"
#import "MHVVocabSearchTask.h"

@class MHVVocabSearcher;

@protocol MHVVocabSearcherDelegate <NSObject>

-(void) resultsAvailable:(MHVVocabCodeSet *) results forSearch:(NSString *) searchText inSearcher:(MHVVocabSearcher *) searcher 
seqNumber:(NSUInteger) seq;

-(void) searchFailedFor:(NSString *) search inSearcher:(MHVVocabSearcher *) searcher seqNumber:(NSUInteger) seq;

@end

@interface MHVVocabSearchCache : NSObject
{
@private
    NSCache* m_cache;
    MHVVocabCodeSet* m_emptySet;
}

@property (readonly, nonatomic) NSCache* cache; 
@property (readwrite, nonatomic) NSUInteger maxCachedResults; 

-(id) init;
-(id) initWithCache:(NSCache *) cache;

//
// All searches are case IN-SENSITIVE
//
-(BOOL) hasCachedResultsForSearch:(NSString *) searchText;

-(MHVVocabCodeSet *) getResultsForSearch:(NSString *) searchText;
-(void) cacheResults:(MHVVocabCodeSet *) results forSearch:(NSString *) searchText;
-(void) removeCachedResultsForSearch:(NSString *) searchText;

-(void) ensureDummyEntryForSearch:(NSString *) searchText;

-(NSString *) normalizeSearchText:(NSString *) searchText;

@end

//
// You use this for your AutoComplete data sources
// 1. Searches a specified vocabulary
// 2. Maintains an internal cache to reduce roundtrips
// 3. All completions in UI thread
//
@interface MHVVocabSearcher : NSObject
{
@private
    MHVVocabIdentifier* m_vocab;
    MHVVocabSearchCache* m_cache;
    enum MHVVocabMatchType m_matchType;
    int m_maxResults;
    NSUInteger m_seqNumber;

    id<MHVVocabSearcherDelegate> m_delegate; // Weak reference
}

@property (readwrite, nonatomic, strong) MHVVocabIdentifier* vocab;
@property (readwrite, nonatomic) enum MHVVocabMatchType matchType;
@property (readwrite, nonatomic) int maxResults;
//
// Search cache. 
// Readwrite - you can potentially share caches, or hold onto them
//
@property (readwrite, nonatomic, strong) MHVVocabSearchCache* cache;
//
// DELEGATE
// Weak reference
//
@property (readwrite, nonatomic, weak) id<MHVVocabSearcherDelegate> delegate;

-(id) initWithVocab:(MHVVocabIdentifier *) vocab;
-(id) initWithVocab:(MHVVocabIdentifier *)vocab andMaxResults:(int) max;

-(MHVVocabSearchTask *) searchFor:(NSString *) text;

@end
