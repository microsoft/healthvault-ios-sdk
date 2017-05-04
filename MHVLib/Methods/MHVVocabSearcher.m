//
//  MHVVocabSearcher.m
//  MHVLib
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
#import "MHVCommon.h"
#import "MHVVocabSearcher.h"
#import "MHVBlock.h"

@implementation MHVVocabSearchCache

@synthesize cache = m_cache;

-(NSUInteger)maxCachedResults
{
    return [m_cache countLimit];
}

-(void)setMaxCachedResults:(NSUInteger)maxCachedResults
{
    [m_cache setCountLimit:maxCachedResults];
}

-(id)init
{
    return [self initWithCache:nil];
}

-(id)initWithCache:(NSCache *)cache
{
    self = [super init];
    MHVCHECK_SELF;
    
    if (!cache)
    {
        m_cache = [[NSCache alloc] init];
    }
    else 
    {
        m_cache = cache;
    }
    
    MHVCHECK_NOTNULL(m_cache);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
   
}


-(BOOL)hasCachedResultsForSearch:(NSString *)searchText
{
    return ([self getResultsForSearch:searchText] != nil);
}

-(MHVVocabCodeSet *)getResultsForSearch:(NSString *)searchText
{
    if ([NSString isNilOrEmpty:searchText])
    {
        return nil;
    }
    
    return [m_cache objectForKey:[searchText lowercaseString]];
}

-(void)cacheResults:(MHVVocabCodeSet *)results forSearch:(NSString *)searchText
{
    if (!results)
    {
        return;
    }
    
    if ([NSString isNilOrEmpty:searchText])
    {
        return;
    }
    
    [m_cache setObject:results forKey:[searchText lowercaseString]];
}

-(void)removeCachedResultsForSearch:(NSString *)searchText
{
    [m_cache removeObjectForKey:searchText];
}

-(void) ensureDummyEntryForSearch:(NSString *)searchText
{
    if (!searchText)
    {
        return;
    }
    
    if (![self hasCachedResultsForSearch:searchText])
    {
        MHVENSURE(m_emptySet, MHVVocabCodeSet);
        [self cacheResults:m_emptySet forSearch:searchText];
    }
}

-(NSString *)normalizeSearchText:(NSString *)searchText
{
    return [searchText lowercaseString];
}

@end

@interface MHVVocabSearcher (MHVPrivate)

-(void) searchComplete:(MHVVocabSearchTask *) task forString:(NSString *) searchText seqNumber:(NSUInteger) seq;
-(void) notifySearchComplete:(MHVVocabCodeSet *) results forSearch:(NSString *) searchText seqNumber:(NSUInteger) seq;
-(void) notifySearchFailedFor:(NSString *) searchText seqNumber:(NSUInteger) seq;

@end

@implementation MHVVocabSearcher

@synthesize vocab = m_vocab;
@synthesize matchType = m_matchType;
@synthesize maxResults = m_maxResults;

-(id<MHVVocabSearcherDelegate>)delegate
{
    @synchronized(self)
    {
        return m_delegate;
    }
}

-(void)setDelegate:(id<MHVVocabSearcherDelegate>)delegate
{
    @synchronized(self)
    {
        m_delegate = delegate; // weak reference
    }
}

-(MHVVocabSearchCache *)cache
{
    MHVENSURE(m_cache, MHVVocabSearchCache);
    return m_cache;
}

-(void)setCache:(MHVVocabSearchCache *)cache
{
    if (cache)
    {
        m_cache = cache;
    }
    else 
    {
        m_cache = nil;
        MHVENSURE(m_cache, MHVVocabSearchCache);
    }
}

-(id)initWithVocab:(MHVVocabIdentifier *)vocab
{
    return [self initWithVocab:vocab andMaxResults:25];
}

-(id)initWithVocab:(MHVVocabIdentifier *)vocab andMaxResults:(int)max
{
    MHVCHECK_NOTNULL(vocab);
    
    m_vocab = vocab;
    m_maxResults = max;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVVocabSearchTask *)searchFor:(NSString *)text
{
    NSUInteger seqNumber;
    @synchronized(self)
    {
        seqNumber = ++m_seqNumber;
    }
    
    MHVVocabCodeSet* results = [self.cache getResultsForSearch:text];
    
    if (results)
    {
        [m_delegate resultsAvailable:results forSearch:text inSearcher:self seqNumber:seqNumber];
        return nil;
    }
    //
    // Immediately create a dummy entry in the cache - a simple way to prevent reissuing
    // queries for which results are pending
    //
    [self.cache ensureDummyEntryForSearch:text];
    
    return [MHVVocabSearchTask searchForText:text inVocab:m_vocab callback:^(MHVTask *task) {
        
        [self searchComplete:(MHVVocabSearchTask *) task forString:text seqNumber:seqNumber];
        
    }];
}


@end

@implementation MHVVocabSearcher (MHVPrivate)

-(void)searchComplete:(MHVVocabSearchTask *)task forString:(NSString *)searchText seqNumber:(NSUInteger)seq
{    
    @try 
    {
        MHVVocabCodeSet* results = task.searchResult;
        if (results)
        {
            [self.cache cacheResults:results forSearch:searchText];
        }
        
        [self notifySearchComplete:results forSearch:searchText seqNumber:seq];
    }
    @catch (id ex) 
    {
        [self.cache removeCachedResultsForSearch:searchText];
        
        [self notifySearchFailedFor:searchText seqNumber:seq];
        [ex log];
    }
}

-(void)notifySearchComplete:(MHVVocabCodeSet *)results forSearch:(NSString *)searchText seqNumber:(NSUInteger) seq
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate resultsAvailable:results forSearch:searchText inSearcher:self seqNumber:seq];
            }
        }
    },  TRUE);
}

-(void)notifySearchFailedFor:(NSString *)searchText seqNumber:(NSUInteger) seq
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate searchFailedFor:searchText inSearcher:self seqNumber:seq];
            }
        }
    },  TRUE);
}

@end
