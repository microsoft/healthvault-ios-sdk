//
// MHVTypeView.m
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

#import "MHVCommon.h"
#import "MHVTypeView.h"
#import "MHVSynchronizedStore.h"
#import "MHVClientException.h"
#import "MHVBlock.h"
#import "MHVClient.h"

static NSString *const c_element_typeID = @"typeID";
static NSString *const c_element_filter = @"filter";
static NSString *const c_element_updateDate = @"updateDate";
static NSString *const c_element_things = @"things";
static NSString *const c_element_chunkSize = @"chunkSize";
static NSString *const c_element_maxThings = @"maxThings";

const int c_hvTypeViewDefaultReadAheadChunkSize = 50;

@implementation MHVTypeView

@synthesize typeID = m_typeID;
@synthesize filter = m_filter;
@synthesize lastUpdateDate = m_lastUpdateDate;
@synthesize maxThings = m_maxThings;
@synthesize store = m_store;
@synthesize tag = m_tag;

- (BOOL)readAheadModeChunky
{
    return m_readAheadMode == MHVTypeViewReadAheadModePage;
}

- (void)setReadAheadModeChunky:(BOOL)readAheadModeChunky
{
    if (readAheadModeChunky)
    {
        m_readAheadMode = MHVTypeViewReadAheadModePage;
    }
    else
    {
        m_readAheadMode = MHVTypeViewReadAheadModeSequential;
    }
}

@synthesize readAheadMode = m_readAheadMode;

- (NSInteger)readAheadChunkSize
{
    return m_readAheadChunkSize;
}

- (void)setReadAheadChunkSize:(NSInteger)readAheadChunkSize
{
    if (readAheadChunkSize > 0)
    {
        m_readAheadChunkSize = readAheadChunkSize;
    }
    else
    {
        m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    }
}

@synthesize enforceTypeCheck = m_enforceTypeCheck;

- (MHVRecordReference *)record
{
    return m_store.record;
}

- (NSDate *)lastUpdateDate
{
    if (!m_lastUpdateDate)
    {
        [self stampUpdated];
    }

    return m_lastUpdateDate;
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate
{
    m_lastUpdateDate = lastUpdateDate;
}

- (void)setStore:(MHVLocalRecordStore *)store
{
    MHVASSERT(store);
    m_store = store;
}

- (NSUInteger)count
{
    return m_things.count;
}

- (NSDate *)minDate
{
    return m_things.minDate;
}

- (NSDate *)maxDate
{
    return m_things.maxDate;
}

// We need a default vanilla constructor for Xml serialization
- (id)init
{
    return [super init];
}

- (id)initForTypeID:(NSString *)typeID overStore:(MHVLocalRecordStore *)store
{
    return [self initForTypeID:typeID filter:nil overStore:store];
}

- (id)initForTypeID:(NSString *)typeID filter:(MHVTypeFilter *)filter overStore:(MHVLocalRecordStore *)store
{
    return [self initForTypeID:typeID filter:filter things:nil overStore:store];
}

- (id)initForTypeID:(NSString *)typeID filter:(MHVTypeFilter *)filter things:(MHVTypeViewThings *)things overStore:(MHVLocalRecordStore *)store
{
    MHVCHECK_NOTNULL(typeID);
    MHVCHECK_NOTNULL(store);

    self = [super init];
    MHVCHECK_SELF;

    self.typeID = typeID;
    self.filter = filter;
    self.store = store;
    m_readAheadMode = MHVTypeViewReadAheadModePage;
    m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    self.enforceTypeCheck = FALSE;
    if (things)
    {
        m_things = things;
    }
    else
    {
        m_things = [[MHVTypeViewThings alloc] init];
    }

    return self;

   LError:
    MHVALLOC_FAIL;
}

- (id)initFromTypeView:(MHVTypeView *)typeView andThings:(MHVTypeViewThings *)things
{
    MHVCHECK_NOTNULL(typeView);

    self = [self initForTypeID:typeView.typeID filter:typeView.filter things:things overStore:typeView.store];
    MHVCHECK_SELF;

    m_readAheadMode = typeView.readAheadMode;

    return self;

   LError:
    MHVALLOC_FAIL;
}

- (MHVThingKey *)keyAtIndex:(NSUInteger)index
{
    return [self thingKeyAtIndex:index];
}

- (MHVTypeViewThing *)thingKeyAtIndex:(NSUInteger)index
{
    return [m_things objectAtIndex:index];
}

- (NSUInteger)indexOfThingID:(NSString *)thingID
{
    return [m_things indexOfThingID:thingID];
}

- (void)removeKeyAtIndex:(NSUInteger)index
{
    [m_things removeThingAtIndex:index];
}

- (NSUInteger)insertKeyForThing:(MHVThing *)thing
{
    return [m_things insertHVThingInOrder:thing];
}

- (BOOL)updateKeyForThing:(MHVThing *)thing
{
    return [m_things updateMHVThing:thing];
}

- (NSUInteger)indexOfThingWithClosestDate:(NSDate *)date
{
    return [self indexOfThingWithClosestDate:date firstEqual:TRUE];
}

- (NSUInteger)indexOfThingWithClosestDate:(NSDate *)date firstEqual:(BOOL)firstEqual
{
    NSBinarySearchingOptions searchOptions = NSBinarySearchingInsertionIndex;

    if (firstEqual)
    {
        searchOptions |= NSBinarySearchingFirstEqual;
    }
    else
    {
        searchOptions |= NSBinarySearchingLastEqual;
    }

    NSUInteger index = [m_things searchForThing:date options:searchOptions usingComparator:^(id o1, id o2) {
        MHVTypeViewThing *thing;
        NSComparisonResult cmp;
        if (date == o1)
        {
            thing = (MHVTypeViewThing *)o2;
            cmp = [date compareDescending:thing.date];
        }
        else
        {
            thing = (MHVTypeViewThing *)o1;
            cmp = [thing.date compareDescending:date];
        }

        return cmp;
    }];

    if (index != NSNotFound && index == m_things.count)
    {
        if (m_things.count == 0)
        {
            index = NSNotFound;
        }
        else
        {
            index = m_things.count - 1;
        }
    }

    return index;
}

- (NSUInteger)indexOfFirstDay:(NSDate *)date
{
    NSDate *day = [date toStartOfDay];
    NSUInteger index = [self indexOfThingWithClosestDate:day];

    if (index == NSNotFound)
    {
        return index;
    }

    return [self indexOfFirstDay:date startAt:index];
}

- (NSUInteger)indexOfFirstDay:(NSDate *)date startAt:(NSUInteger)baseIndex
{
    NSUInteger index = baseIndex;

    NSCalendar *calendar = [NSCalendar newGregorian];
    NSDateComponents *baseComponents = [calendar getComponentsFor:date];

    for (; index > 0; --index)
    {
        NSDateComponents *thingComponents = [calendar getComponentsFor:[self thingKeyAtIndex:index].date];
        NSComparisonResult cmp = [NSDateComponents compareYearMonthDay:thingComponents and:baseComponents];
        if (cmp == NSOrderedDescending)
        {
            index++;
            break;
        }
    }

    if (index >= self.count)
    {
        index = self.count - 1;
    }

    return index;
}

- (BOOL)containsThingID:(NSString *)thingID
{
    return [self indexOfThingID:thingID] != NSNotFound;
}

- (MHVTypeViewThing *)thingForThingID:(NSString *)thingID
{
    NSUInteger index = [self indexOfThingID:thingID];

    if (index == NSNotFound)
    {
        return nil;
    }

    return [self thingKeyAtIndex:index];
}

- (MHVThing *)getLocalThingAtIndex:(NSUInteger)index
{
    return [self getLocalThingWithKey:[self thingKeyAtIndex:index]];
}

- (MHVThing *)getLocalThingWithKey:(MHVThingKey *)key
{
    MHVThing *thing = [m_store.data getLocalThingWithKey:key];

    if (thing && m_enforceTypeCheck)
    {
        if (![thing isType:m_typeID])
        {
            thing = nil;
        }
    }

    return thing;
}

- (void)removeLocalThingAtIndex:(NSUInteger)index
{
    return [m_store.data removeLocalThingWithKey:[self thingKeyAtIndex:index]];
}

- (void)removeAllLocalThings
{
    @autoreleasepool
    {
        for (NSUInteger i = 0, count = m_things.count; i < count; ++i)
        {
            [self removeLocalThingAtIndex:i];
        }
    }
}

- (MHVThing *)getThingAtIndex:(NSUInteger)index
{
    return [self getThingAtIndex:index readAheadCount:m_readAheadChunkSize];
}

- (MHVThing *)getThingByID:(NSString *)thingID
{
    NSUInteger index = [self indexOfThingID:thingID];

    if (index == NSNotFound)
    {
        return nil;
    }

    return [self getThingAtIndex:index];
}

- (MHVThing *)getThingAtIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    if (readAheadCount == 0)
    {
        readAheadCount = c_hvTypeViewDefaultReadAheadChunkSize;
    }

    MHVTypeViewThing *key = [m_things objectAtIndex:index];
    MHVCHECK_NOTNULL(key);

    if (key.isLoadPending)
    {
        return nil; // Will be delivered via delegate
    }

    //
    // Check if we already have this thing
    //
    MHVThing *thing = [self getLocalThingWithKey:key];
    if (thing)
    {
        return thing;
    }

    //
    // Find the things we don't already have cached, and start loading them
    //
    NSRange range;
    if (m_readAheadMode == MHVTypeViewReadAheadModePage)
    {
        range = [self getChunkForIndex:index chunkSize:readAheadCount];
    }
    else
    {
        range = [self getReadAheadRangeForIndex:index readAheadCount:readAheadCount];
    }

    MHVThingCollection *things = [self getThingsInRange:range nullIfNotFound:FALSE];
    //
    // In case one showed up while we were working
    //
    if (![MHVCollection isNilOrEmpty:things])
    {
        return [things objectAtIndex:0];
    }

   LError:
    return nil;
}

- (MHVThingCollection *)getThingsInRange:(NSRange)range
{
    return [self getThingsInRange:range downloadTask:nil];
}

- (MHVThingCollection *)getThingsInRange:(NSRange)range downloadTask:(MHVTask **)task
{
    return [self getThingsInRange:range nullIfNotFound:TRUE downloadTask:task];
}

- (MHVThingCollection *)getThingsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull
{
    return [self getThingsInRange:range nullIfNotFound:includeNull downloadTask:nil];
}

- (MHVThingCollection *)getThingsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull downloadTask:(MHVTask **)task
{
    range = [m_things correctRange:range];
    if (range.length == 0)
    {
        return nil;
    }

    if (task)
    {
        *task = nil;
    }

    MHVThingKeyCollection *pendingKeys = nil;
    //
    // Fetch local things
    //
    MHVThingCollection *things = [self getLocalThingsInRange:range andPendingList:&pendingKeys nullForNotFound:includeNull];
    //
    // Download any pending things...
    //
    if (![MHVCollection isNilOrEmpty:pendingKeys])
    {
        MHVTask *downloadTask = [self downloadThingsWithKeys:pendingKeys];
        if (task)
        {
            *task = downloadTask;
        }
    }

    return things;
}

- (MHVThingKeyCollection *)keysOfThingsNeedingDownloadInRange:(NSRange)range
{
    MHVThingKeyCollection *pendingKeys = nil;

    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVThing *thing = [self getLocalThingAtIndex:i];
        if (!thing)
        {
            if (!pendingKeys)
            {
                pendingKeys = [MHVThingKeyCollection new];
                MHVCHECK_NOTNULL(pendingKeys);
            }

            MHVTypeViewThing *key = [m_things objectAtIndex:i];
            [pendingKeys addObject:key];
        }
    }

    return pendingKeys;

   LError:
    return nil;
}

- (MHVTask *)ensureThingsDownloadedInRange:(NSRange)range withCallback:(MHVTaskCompletion)callback
{
    MHVThingKeyCollection *pendingKeys = [self keysOfThingsNeedingDownloadInRange:range];

    if ([MHVCollection isNilOrEmpty:pendingKeys])
    {
        return nil;
    }

    MHVTask *task = [m_store.data newDownloadThingsInRecord:m_store.record forKeys:pendingKeys callback:callback];
    if (!task)
    {
        return nil;
    }

    task.shouldCompleteInMainThread = TRUE;
    [task start];

    return task;
}

- (NSUInteger)putThing:(MHVThing *)thing
{
    //
    // First, place in the persistent store
    //
    if (![m_store.data putLocalThing:thing])
    {
        return NSNotFound;
    }

    NSUInteger index = [m_things insertHVThingInOrder:thing];

    [self stampUpdated];

    return index;
}

- (BOOL)putThings:(MHVThingCollection *)things
{
    MHVCHECK_NOTNULL(things);

    for (MHVThing *thing in things)
    {
        [self putThing:thing];
    }

    [self stampUpdated];

    return TRUE;

   LError:
    return FALSE;
}

- (BOOL)removeThingAtIndex:(NSUInteger)index
{
    [self removeLocalThingAtIndex:index];
    [m_things removeThingAtIndex:index];
    [self stampUpdated];
    return TRUE;
}

- (NSUInteger)updateThingInView:(MHVThing *)thing prevIndex:(NSUInteger *)prevIndex
{
    NSUInteger indexAt = [m_things indexOfThingID:thing.thingID];

    if (prevIndex)
    {
        *prevIndex = indexAt;
    }

    NSUInteger newIndex;
    if (indexAt != NSNotFound)
    {
        [m_things removeThingAtIndex:indexAt];
    }

    newIndex = [m_things insertHVThingInOrder:thing];

    [self stampUpdated];

    return newIndex;
}

- (NSUInteger)updateThingInView:(MHVThing *)thing
{
    return [self updateThingInView:thing prevIndex:nil];
}

- (BOOL)removeThingFromViewByID:(NSString *)thingID
{
    if ([m_things removeThingByID:thingID] == NSNotFound)
    {
        return FALSE;
    }

    [self stampUpdated];
    return TRUE;
}

- (BOOL)removeThingsFromViewByID:(NSArray *)thingIDs
{
    if ([NSArray isNilOrEmpty:thingIDs])
    {
        return FALSE;
    }

    BOOL changed = FALSE;
    for (NSString *thingID in thingIDs)
    {
        if ([m_things removeThingByID:thingID] != NSNotFound)
        {
            changed = TRUE;
        }
    }

    if (changed)
    {
        [self stampUpdated];
    }

    return changed;
}

- (BOOL)isStale:(NSTimeInterval)maxAge
{
    if (!m_lastUpdateDate)
    {
        return TRUE;
    }

    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:m_lastUpdateDate] > maxAge;
}

- (MHVTask *)synchronize
{
    return [self refresh];
}

- (MHVTask *)refresh
{
    MHVGetThingsTask *getThings = [self newRefreshTask];

    MHVCHECK_NOTNULL(getThings);

    [getThings start];

    return getThings;

   LError:
    return nil;
}

- (MHVTask *)refreshWithCallback:(MHVTaskCompletion)callback
{
    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];

    MHVCHECK_NOTNULL(task);

    MHVGetThingsTask *syncTask = [self newRefreshTask];
    MHVCHECK_NOTNULL(syncTask);

    [task setNextTask:syncTask];

    [task start];
    return task;

   LError:
    return nil;
}

- (MHVThingQuery *)getQuery
{
    return [self newRefreshQuery];
}

- (BOOL)replaceKeys:(MHVTypeViewThings *)things
{
    MHVCHECK_NOTNULL(things);

    [self updateViewWith:things];
    [self notifySynchronized];

    return TRUE;

   LError:
    return FALSE;
}

- (MHVTask *)synchronizeData
{
    return [self synchronizeDataInRange:NSMakeRange(0, m_things.count)];
}

- (MHVTask *)synchronizeDataInRange:(NSRange)range
{
    range = [m_things correctRange:range];
    return [m_store.data downloadThingsWithKeys:[m_things keysInRange:range] inView:self];
}

- (BOOL)save
{
    return [self saveWithName:self.typeID];
}

- (BOOL)saveWithName:(NSString *)name
{
    return [m_store putView:self name:name];
}

+ (MHVTypeView *)loadViewNamed:(NSString *)name fromStore:(MHVLocalRecordStore *)store
{
    return [store getView:name];
}

+ (MHVTypeView *)getViewForTypeClassName:(NSString *)className inRecord:(MHVRecordReference *)record
{
    NSString *typeID = [[MHVTypeSystem current] getTypeIDForClassName:className];

    return [MHVTypeView getViewForTypeID:typeID inRecord:record];
}

+ (MHVTypeView *)getViewForTypeID:(NSString *)typeID inRecord:(MHVRecordReference *)record
{
    MHVLocalRecordStore *recordStore = [[MHVClient current].localVault getRecordStore:record];

    return [MHVTypeView getViewForTypeID:typeID andRecordStore:recordStore];
}

+ (MHVTypeView *)getViewForTypeID:(NSString *)typeID andRecordStore:(MHVLocalRecordStore *)store
{
    MHVCHECK_NOTNULL(store);

    MHVTypeView *view = [MHVTypeView loadViewNamed:typeID fromStore:store];
    if (!view)
    {
        view = [[MHVTypeView alloc] initForTypeID:typeID overStore:store];
    }

    return view;

   LError:
    return nil;
}

- (void)updateViewWith:(MHVTypeViewThings *)things
{
    m_things = nil;
    m_things = things;
    [self stampUpdated];
}

// -------------------------
//
// Called by SynchronizedStore.
// These can come in on any thread. We can do local computation, but
// we must push all changes we need to make to TypeView - to the Main thread
//
// ------------------------
- (void)keysNotRetrieved:(NSArray *)keys withError:(id)error
{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:2];

    [params addObject:keys];
    [params addObject:error];

    [self invokeOnMainThread:@selector(keysFailed:) withObject:params];
}

- (void)thingsRetrieved:(MHVThingCollection *)things forKeys:(MHVThingKeyCollection *)keys
{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:2];

    [params addObject:things];
    [params addObject:keys];

    [self invokeOnMainThread:@selector(processThingsRetrieved:) withObject:params];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_typeID value:m_typeID];
    [writer writeElement:c_element_filter content:m_filter];
    [writer writeElement:c_element_updateDate dateValue:m_lastUpdateDate];
    [writer writeElement:c_element_things content:m_things];
    [writer writeElement:c_element_chunkSize intValue:(int)m_readAheadChunkSize];
    [writer writeElement:c_element_maxThings intValue:(int)m_maxThings];
}

- (void)deserialize:(XReader *)reader
{
    m_typeID = [reader readStringElement:c_element_typeID];
    m_filter = [reader readElement:c_element_filter asClass:[MHVThingFilter class]];
    m_lastUpdateDate = [reader readDateElement:c_element_updateDate];
    m_things = [reader readElement:c_element_things asClass:[MHVTypeViewThings class]];
    m_readAheadChunkSize = [reader readIntElement:c_element_chunkSize];
    if (m_readAheadChunkSize <= 0)
    {
        m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    }

    m_maxThings = [reader readIntElement:c_element_maxThings];
}

- (MHVTypeView *)subviewForRange:(NSRange)range
{
    MHVTypeViewThings *subThings = [[MHVTypeViewThings alloc] init];

    if (m_things)
    {
        [m_things correctRange:range];
        for (NSUInteger i = 0, max = NSMaxRange(range); i < max; ++i)
        {
            [subThings addObject:[m_things objectAtIndex:i]];
        }
    }

    return [[MHVTypeView alloc] initFromTypeView:self andThings:subThings];
}

- (void)setTypeID:(NSString *)typeID
{
    m_typeID = typeID;
}

- (void)setFilter:(MHVTypeFilter *)filter
{
    m_filter = filter;
}

- (void)setThings:(MHVTypeViewThings *)things
{
    m_things = things;
}

- (MHVThingQuery *)newRefreshQuery
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithTypeID:m_typeID];

    MHVCHECK_NOTNULL(query);

    query.view.sections = MHVThingSection_Core;
    if (m_filter)
    {
        [query.filters addObject:m_filter];
    }

    if (m_maxThings > 0)
    {
        query.maxResults = (int)m_maxThings;
    }

    query.maxFullResults = 0;
    return query;

   LError:
    return nil;
}

- (MHVGetThingsTask *)newRefreshTask
{
    MHVThingQuery *query = [self newRefreshQuery];

    MHVCHECK_NOTNULL(query);

    MHVGetThingsTask *getThings = [[MHVClient current].methodFactory newGetThingsForRecord:self.record query:query andCallback:^(MHVTask *task) {
        if (![NSThread isMainThread])
        {
            [self invokeOnMainThread:@selector(synchronizeViewCompleted:) withObject:task];
        }
        else
        {
            [self synchronizeViewCompleted:task];
        }
    }];
    getThings.shouldCompleteInMainThread = TRUE;

    return getThings;

   LError:
    return nil;
}

//
// This MUST always be called in the main UI thread
//
- (void)synchronizeViewCompleted:(MHVTask *)task
{
    MHVTypeViewThings *newViewThings = [[MHVTypeViewThings alloc] init];

    @try
    {
        MHVThingQueryResults *results = task.result;

        if (results.hasResults)
        {
            MHVThingQueryResult *result = results.firstResult;
            if (![newViewThings addQueryResult:result])
            {
                [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_Sync)];
            }
        }

        self.things = newViewThings;

        [self stampUpdated];

        [self notifySynchronized];
    }
    @catch (id ex)
    {
        [ex log];
        [self notifySyncFailed:ex];
    }
    @finally
    {
        newViewThings = nil;
    }
}

- (NSRange)getChunkForIndex:(NSUInteger)index chunkSize:(NSUInteger)chunkSize
{
    NSUInteger chunk = index / chunkSize;
    NSUInteger chunkStartAt = chunk * chunkSize;
    NSRange range = [m_things correctRange:NSMakeRange(chunkStartAt, chunkSize)];

    return range;
}

- (NSRange)getReadAheadRangeForIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    return [m_things correctRange:NSMakeRange(index, readAheadCount)];
}

- (MHVThingCollection *)getLocalThingsInRange:(NSRange)range andPendingList:(MHVThingKeyCollection **)pending nullForNotFound:(BOOL)includeNull
{
    *pending = nil;

    MHVThingKeyCollection *pendingKeys = nil;
    MHVThingCollection *things = [[MHVThingCollection alloc] initWithCapacity:range.length];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVTypeViewThing *key = [m_things objectAtIndex:i];
        MHVThing *thing = [self getLocalThingWithKey:key];
        if (thing)
        {
            [things addObject:thing];
        }
        else
        {
            if (!pendingKeys)
            {
                pendingKeys = [MHVThingKeyCollection new];
                MHVCHECK_NOTNULL(pendingKeys);
            }

            [pendingKeys addObject:key];

            if (includeNull)
            {
                [things addObject:(MHVThing *)[NSNull null]];
            }
        }
    }

    *pending = pendingKeys;
    return things;

   LError:
    return nil;
}

- (MHVTask *)downloadThingsWithKeys:(MHVThingKeyCollection *)keys
{
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return nil;
    }

    //
    // This will remove any keys that have pending loads...
    //
    [self prepareKeysForLoading:keys];
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return nil;
    }

    //
    // Launch the download task
    //
    MHVTask *task = [m_store.data downloadThingsWithKeys:keys typeID:m_typeID inView:self];
    if (task != nil)
    {
        return task;
    }

    //
    // Failed...
    //
    [self setDownloadStatus:FALSE forKeys:keys];

    return task;
}

//
// Keys that have pending loads are removed from the list
// The remainder are marked as loading..
//
- (void)prepareKeysForLoading:(MHVThingKeyCollection *)keys
{
    NSUInteger i = 0;
    NSUInteger count = keys.count;

    while (i < count)
    {
        MHVTypeViewThing *key = (MHVTypeViewThing *)[keys objectAtIndex:i];
        if (key.isLoadPending)
        {
            [keys removeObjectAtIndex:i];
            --count;
        }
        else
        {
            key.isLoadPending = TRUE;
            ++i;
        }
    }
}

- (BOOL)updateThingsInView:(MHVThingCollection *)things
{
    if ([MHVCollection isNilOrEmpty:things])
    {
        return FALSE;
    }

    BOOL changed = FALSE;
    for (NSUInteger i = 0, count = things.count; i < count; ++i)
    {
        if ([m_things updateMHVThing:[things objectAtIndex:i]])
        {
            changed = TRUE;
        }
    }

    if (changed)
    {
        [self stampUpdated];
    }

    return changed;
}

- (BOOL)removeThingsForKeys:(MHVThingKeyCollection *)keys
{
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return TRUE;
    }

    @try
    {
        for (NSUInteger i = 0, count = keys.count; i < count; ++i)
        {
            MHVThingKey *key = [keys objectAtIndex:i];

            [m_store.data removeLocalThingWithKey:key];
            [m_things removeThingByID:key.thingID];
        }

        [self stampUpdated];

        return TRUE;
    }
    @catch (id exception)
    {
        [exception log];
    }

    return FALSE;
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)processThingsRetrieved:(NSArray *)params
{
    MHVThingCollection *things = [params objectAtIndex:0];
    MHVThingKeyCollection *keys = [params objectAtIndex:1];

    if (things && things.count > 0)
    {
        [self thingsAvailableInStore:things];
    }

    //
    // Not all keys may have resulted in things being retrieved
    //
    MHVThingKeyCollection *keysNotFound = [self selectKeys:keys notIn:things];
    if (![MHVCollection isNilOrEmpty:keysNotFound])
    {
        [self keysNotAvailableInStore:keysNotFound];
    }
}

- (MHVThingKeyCollection *)selectKeys:(MHVThingKeyCollection *)keys notIn:(MHVThingCollection *)things
{
    if (things.count >= keys.count)
    {
        return nil;
    }

    NSMutableDictionary *thingsByID = [things newIndexByID];
    if (!thingsByID)
    {
        return nil;
    }

    MHVThingKeyCollection *keysNotFound = [MHVThingKeyCollection new];
    for (MHVThingKey *key in keys)
    {
        if (![thingsByID objectForKey:key.thingID])
        {
            [keysNotFound addObject:key];
        }
    }

    return keysNotFound;
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)thingsAvailableInStore:(MHVThingCollection *)things
{
    [self setDownloadStatus:FALSE forThings:things];

    BOOL viewChanged = [self updateThingsInView:things];

    [self notifyThingsAvailable:things viewChanged:viewChanged];
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)keysNotAvailableInStore:(MHVThingKeyCollection *)keys
{
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return;
    }

    //
    // Let the view clean itself up
    //
    [self removeThingsForKeys:keys];
    //
    // Let the subscriber know that some keys are not found and we had to clean up
    //
    [self notifyKeysNotAvailable:keys];
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)keysFailed:(NSArray *)params
{
    MHVThingKeyCollection *keys = [params objectAtIndex:0];
    id error = [params objectAtIndex:1];

    [self setDownloadStatus:FALSE forKeys:keys];
    [self notifySyncFailed:error];
}

- (void)setDownloadStatus:(BOOL)status forIndex:(NSUInteger)index
{
    MHVTypeViewThing *key = [self thingKeyAtIndex:index];

    if (key)
    {
        key.isLoadPending = status;
    }
}

- (void)setDownloadStatus:(BOOL)status forKeys:(MHVThingKeyCollection *)keys
{
    for (MHVTypeViewThing *key in keys)
    {
        key.isLoadPending = status;
    }
}

- (void)setDownloadStatus:(BOOL)status forThings:(MHVThingCollection *)things
{
    for (MHVThing *thing in things)
    {
        MHVTypeViewThing *key = [m_things objectForThingID:thing.thingID];
        if (key)
        {
            key.isLoadPending = status;
        }
    }
}

- (void)notifyThingsAvailable:(MHVThingCollection *)things viewChanged:(BOOL)viewChanged
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate thingsAvailable:things inView:self viewChanged:viewChanged];
        }
    });
}

- (void)notifyKeysNotAvailable:(MHVThingKeyCollection *)keys
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate keysNotAvailable:keys inView:self];
        }
    });
}

- (void)notifySynchronized
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizationCompletedInView:self];
        }
    });
}

- (void)notifySyncFailed:(id)error
{
    safeInvokeActionEx (^{
        if (self.delegate)
        {
            [self.delegate synchronizationFailedInView:self withError:error];
        }
    }, TRUE);  // Ensures that delegate is called in UI thread
}

- (void)stampUpdated
{
    self.lastUpdateDate = [NSDate date];
}

@end
