//
//  HVVocabSearcher.m
//  HVLib
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
#import "HVCommon.h"
#import "HVVocabSearcher.h"
#import "HVBlock.h"

@implementation HVVocabSearchCache

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
    HVCHECK_SELF;
    
    if (!cache)
    {
        m_cache = [[NSCache alloc] init];
    }
    else 
    {
        HVRETAIN(m_cache, cache);
    }
    
    HVCHECK_NOTNULL(m_cache);
    
    return self;
    
LError:
    HVALLOC_FAIL;
   
}

-(void)dealloc
{
    [m_cache release];
    [super dealloc];
}

-(BOOL)hasCachedResultsForSearch:(NSString *)searchText
{
    return ([self getResultsForSearch:searchText] != nil);
}

-(HVVocabCodeSet *)getResultsForSearch:(NSString *)searchText
{
    if ([NSString isNilOrEmpty:searchText])
    {
        return nil;
    }
    
    return [m_cache objectForKey:[searchText lowercaseString]];
}

-(void)cacheResults:(HVVocabCodeSet *)results forSearch:(NSString *)searchText
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
        HVENSURE(m_emptySet, HVVocabCodeSet);
        [self cacheResults:m_emptySet forSearch:searchText];
    }
}

-(NSString *)normalizeSearchText:(NSString *)searchText
{
    return [searchText lowercaseString];
}

@end

@interface HVVocabSearcher (HVPrivate)

-(void) searchComplete:(HVVocabSearchTask *) task forString:(NSString *) searchText seqNumber:(NSUInteger) seq;
-(void) notifySearchComplete:(HVVocabCodeSet *) results forSearch:(NSString *) searchText seqNumber:(NSUInteger) seq;
-(void) notifySearchFailedFor:(NSString *) searchText seqNumber:(NSUInteger) seq;

@end

@implementation HVVocabSearcher

@synthesize vocab = m_vocab;
@synthesize matchType = m_matchType;
@synthesize maxResults = m_maxResults;

-(id<HVVocabSearcherDelegate>)delegate
{
    @synchronized(self)
    {
        return m_delegate;
    }
}

-(void)setDelegate:(id<HVVocabSearcherDelegate>)delegate
{
    @synchronized(self)
    {
        m_delegate = delegate; // weak reference
    }
}

-(HVVocabSearchCache *)cache
{
    HVENSURE(m_cache, HVVocabSearchCache);
    return m_cache;
}

-(void)setCache:(HVVocabSearchCache *)cache
{
    if (cache)
    {
        HVRETAIN(m_cache, cache);
    }
    else 
    {
        HVCLEAR(m_cache);
        HVENSURE(m_cache, HVVocabSearchCache);
    }
}

-(id)initWithVocab:(HVVocabIdentifier *)vocab
{
    return [self initWithVocab:vocab andMaxResults:25];
}

-(id)initWithVocab:(HVVocabIdentifier *)vocab andMaxResults:(int)max
{
    HVCHECK_NOTNULL(vocab);
    
    HVRETAIN(m_vocab, vocab);
    m_maxResults = max;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVVocabSearchTask *)searchFor:(NSString *)text
{
    NSUInteger seqNumber;
    @synchronized(self)
    {
        seqNumber = ++m_seqNumber;
    }
    
    HVVocabCodeSet* results = [self.cache getResultsForSearch:text];
    
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
    
    return [HVVocabSearchTask searchForText:text inVocab:m_vocab callback:^(HVTask *task) {
        
        [self searchComplete:(HVVocabSearchTask *) task forString:text seqNumber:seqNumber];
        
    }];
}

-(void)dealloc
{
    [m_vocab release];
    [m_params release];
    [m_cache release];
    [super dealloc];
}

@end

@implementation HVVocabSearcher (HVPrivate)

-(void)searchComplete:(HVVocabSearchTask *)task forString:(NSString *)searchText seqNumber:(NSUInteger)seq
{
    @try 
    {
        HVVocabCodeSet* results = task.searchResult;
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

-(void)notifySearchComplete:(HVVocabCodeSet *)results forSearch:(NSString *)searchText seqNumber:(NSUInteger) seq
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
