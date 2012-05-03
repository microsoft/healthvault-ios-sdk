//
//  HVVocabSearcher.h
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVVocab.h"
#import "HVVocabSearchTask.h"

@class HVVocabSearcher;

@protocol HVVocabSearcherDelegate <NSObject>

-(void) resultsAvailable:(HVVocabCodeSet *) results forSearch:(NSString *) searchText inSearcher:(HVVocabSearcher *) searcher;

-(void) searchFailedFor:(NSString *) search inSearcher:(HVVocabSearcher *) searcher;

@end

@interface HVVocabSearchCache : NSObject
{
@private
    NSCache* m_cache;
    HVVocabCodeSet* m_emptySet;
}

@property (readonly, nonatomic) NSCache* cache; 

-(id) init;
-(id) initWithCache:(NSCache *) cache;

//
// All searches are case IN-SENSITIVE
//
-(BOOL) hasCachedResultsForSearch:(NSString *) searchText;

-(HVVocabCodeSet *) getResultsForSearch:(NSString *) searchText;
-(void) cacheResults:(HVVocabCodeSet *) results forSearch:(NSString *) searchText;
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
@interface HVVocabSearcher : NSObject
{
@private
    HVVocabIdentifier* m_vocab;
    HVVocabSearchParams* m_params;
    HVVocabSearchCache* m_cache;
    enum HVVocabMatchType m_matchType;
    int m_maxResults;
    
    id<HVVocabSearcherDelegate> m_delegate; // Weak reference
}

@property (readwrite, nonatomic, retain) HVVocabIdentifier* vocab;
@property (readwrite, nonatomic) enum HVVocabMatchType matchType;
@property (readwrite, nonatomic) int maxResults;
//
// Search cache. 
// Readwrite - you can potentially share caches, or hold onto them
//
@property (readwrite, nonatomic, retain) HVVocabSearchCache* cache;
//
// DELEGATE
// Weak reference
//
@property (readwrite, nonatomic, assign) id<HVVocabSearcherDelegate> delegate;

-(id) initWithVocab:(HVVocabIdentifier *) vocab;
-(id) initWithVocab:(HVVocabIdentifier *)vocab andMaxResults:(int) max;

-(HVVocabSearchTask *) searchFor:(NSString *) text;

@end
