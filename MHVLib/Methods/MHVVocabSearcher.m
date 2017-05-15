//
// MHVVocabSearcher.m
// MHVLib
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
#import "MHVCommon.h"
#import "MHVVocabSearcher.h"
#import "MHVBlock.h"

@interface MHVVocabSearchCache ()

@property (nonatomic, strong) MHVVocabCodeSet* emptySet;

@end

@implementation MHVVocabSearchCache

- (NSUInteger)maxCachedResults
{
    return [self.cache countLimit];
}

- (void)setMaxCachedResults:(NSUInteger)maxCachedResults
{
    [self.cache setCountLimit:maxCachedResults];
}

- (instancetype)init
{
    return [self initWithCache:nil];
}

- (instancetype)initWithCache:(NSCache *)cache
{
    self = [super init];
    if (self)
    {
        if (!cache)
        {
            _cache = [[NSCache alloc] init];
        }
        else
        {
            _cache = cache;
        }

        MHVCHECK_NOTNULL(_cache);
    }

    return self;
}

- (BOOL)hasCachedResultsForSearch:(NSString *)searchText
{
    return [self getResultsForSearch:searchText] != nil;
}

- (MHVVocabCodeSet *)getResultsForSearch:(NSString *)searchText
{
    if ([NSString isNilOrEmpty:searchText])
    {
        return nil;
    }

    return [self.cache objectForKey:[searchText lowercaseString]];
}

- (void)cacheResults:(MHVVocabCodeSet *)results forSearch:(NSString *)searchText
{
    if (!results)
    {
        return;
    }

    if ([NSString isNilOrEmpty:searchText])
    {
        return;
    }

    [self.cache setObject:results forKey:[searchText lowercaseString]];
}

- (void)removeCachedResultsForSearch:(NSString *)searchText
{
    [self.cache removeObjectForKey:searchText];
}

- (void)ensureDummyEntryForSearch:(NSString *)searchText
{
    if (!searchText)
    {
        return;
    }

    if (![self hasCachedResultsForSearch:searchText])
    {
        if (!self.emptySet)
        {
            self.emptySet = [[MHVVocabCodeSet alloc] init];
        }

        [self cacheResults:self.emptySet forSearch:searchText];
    }
}

- (NSString *)normalizeSearchText:(NSString *)searchText
{
    return [searchText lowercaseString];
}

@end

@interface MHVVocabSearcher ()

@property (readwrite, nonatomic, strong) MHVVocabSearchCache *vocabSearchCache;
@property (nonatomic, assign) NSUInteger seqNumber;

@end

@implementation MHVVocabSearcher

- (MHVVocabSearchCache *)cache
{
    if (!_vocabSearchCache)
    {
        _vocabSearchCache = [[MHVVocabSearchCache alloc] init];
    }

    return _vocabSearchCache;
}

- (void)setCache:(MHVVocabSearchCache *)cache
{
    if (cache)
    {
        _vocabSearchCache = cache;
    }
}

- (instancetype)initWithVocab:(MHVVocabIdentifier *)vocab
{
    return [self initWithVocab:vocab andMaxResults:25];
}

- (instancetype)initWithVocab:(MHVVocabIdentifier *)vocab andMaxResults:(int)max
{
    MHVCHECK_NOTNULL(vocab);

    self = [super init];
    if (self)
    {
        _vocab = vocab;
        _maxResults = max;
    }
    return self;
}

- (MHVVocabSearchTask *)searchFor:(NSString *)text
{
    NSUInteger seqNumber;

    @synchronized(self)
    {
        seqNumber = ++self.seqNumber;
    }

    MHVVocabCodeSet *results = [self.cache getResultsForSearch:text];

    if (results)
    {
        [self.delegate resultsAvailable:results forSearch:text inSearcher:self seqNumber:seqNumber];
        return nil;
    }

    //
    // Immediately create a dummy entry in the cache - a simple way to prevent reissuing
    // queries for which results are pending
    //
    [self.cache ensureDummyEntryForSearch:text];

    return [MHVVocabSearchTask searchForText:text inVocab:self.vocab callback:^(MHVTask *task)
    {
        [self searchComplete:(MHVVocabSearchTask *)task forString:text seqNumber:seqNumber];
    }];
}

#pragma mark - Internal methods

- (void)searchComplete:(MHVVocabSearchTask *)task forString:(NSString *)searchText seqNumber:(NSUInteger)seq
{
    @try
    {
        MHVVocabCodeSet *results = task.searchResult;
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

- (void)notifySearchComplete:(MHVVocabCodeSet *)results forSearch:(NSString *)searchText seqNumber:(NSUInteger)seq
{
    safeInvokeActionEx (^
    {
        @synchronized(self)
        {
            if (self.delegate)
            {
                [self.delegate resultsAvailable:results forSearch:searchText inSearcher:self seqNumber:seq];
            }
        }
    },  TRUE);
}

- (void)notifySearchFailedFor:(NSString *)searchText seqNumber:(NSUInteger)seq
{
    safeInvokeActionEx (^
    {
        @synchronized(self)
        {
            if (self.delegate)
            {
                [self.delegate searchFailedFor:searchText inSearcher:self seqNumber:seq];
            }
        }
    },  TRUE);
}

@end
