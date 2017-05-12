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
static NSString *const c_element_items = @"items";
static NSString *const c_element_chunkSize = @"chunkSize";
static NSString *const c_element_maxItems = @"maxItems";

const int c_hvTypeViewDefaultReadAheadChunkSize = 50;

@implementation MHVTypeView

@synthesize typeID = m_typeID;
@synthesize filter = m_filter;
@synthesize lastUpdateDate = m_lastUpdateDate;
@synthesize maxItems = m_maxItems;
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
    return m_items.count;
}

- (NSDate *)minDate
{
    return m_items.minDate;
}

- (NSDate *)maxDate
{
    return m_items.maxDate;
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
    return [self initForTypeID:typeID filter:filter items:nil overStore:store];
}

- (id)initForTypeID:(NSString *)typeID filter:(MHVTypeFilter *)filter items:(MHVTypeViewItems *)items overStore:(MHVLocalRecordStore *)store
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
    if (items)
    {
        m_items = items;
    }
    else
    {
        m_items = [[MHVTypeViewItems alloc] init];
    }

    return self;

   LError:
    MHVALLOC_FAIL;
}

- (id)initFromTypeView:(MHVTypeView *)typeView andItems:(MHVTypeViewItems *)items
{
    MHVCHECK_NOTNULL(typeView);

    self = [self initForTypeID:typeView.typeID filter:typeView.filter items:items overStore:typeView.store];
    MHVCHECK_SELF;

    m_readAheadMode = typeView.readAheadMode;

    return self;

   LError:
    MHVALLOC_FAIL;
}

- (MHVItemKey *)keyAtIndex:(NSUInteger)index
{
    return [self itemKeyAtIndex:index];
}

- (MHVTypeViewItem *)itemKeyAtIndex:(NSUInteger)index
{
    return [m_items objectAtIndex:index];
}

- (NSUInteger)indexOfItemID:(NSString *)itemID
{
    return [m_items indexOfItemID:itemID];
}

- (void)removeKeyAtIndex:(NSUInteger)index
{
    [m_items removeItemAtIndex:index];
}

- (NSUInteger)insertKeyForItem:(MHVItem *)item
{
    return [m_items insertHVItemInOrder:item];
}

- (BOOL)updateKeyForItem:(MHVItem *)item
{
    return [m_items updateMHVItem:item];
}

- (NSUInteger)indexOfItemWithClosestDate:(NSDate *)date
{
    return [self indexOfItemWithClosestDate:date firstEqual:TRUE];
}

- (NSUInteger)indexOfItemWithClosestDate:(NSDate *)date firstEqual:(BOOL)firstEqual
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

    NSUInteger index = [m_items searchForItem:date options:searchOptions usingComparator:^(id o1, id o2) {
        MHVTypeViewItem *item;
        NSComparisonResult cmp;
        if (date == o1)
        {
            item = (MHVTypeViewItem *)o2;
            cmp = [date compareDescending:item.date];
        }
        else
        {
            item = (MHVTypeViewItem *)o1;
            cmp = [item.date compareDescending:date];
        }

        return cmp;
    }];

    if (index != NSNotFound && index == m_items.count)
    {
        if (m_items.count == 0)
        {
            index = NSNotFound;
        }
        else
        {
            index = m_items.count - 1;
        }
    }

    return index;
}

- (NSUInteger)indexOfFirstDay:(NSDate *)date
{
    NSDate *day = [date toStartOfDay];
    NSUInteger index = [self indexOfItemWithClosestDate:day];

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
        NSDateComponents *itemComponents = [calendar getComponentsFor:[self itemKeyAtIndex:index].date];
        NSComparisonResult cmp = [NSDateComponents compareYearMonthDay:itemComponents and:baseComponents];
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

- (BOOL)containsItemID:(NSString *)itemID
{
    return [self indexOfItemID:itemID] != NSNotFound;
}

- (MHVTypeViewItem *)itemForItemID:(NSString *)itemID
{
    NSUInteger index = [self indexOfItemID:itemID];

    if (index == NSNotFound)
    {
        return nil;
    }

    return [self itemKeyAtIndex:index];
}

- (MHVItem *)getLocalItemAtIndex:(NSUInteger)index
{
    return [self getLocalItemWithKey:[self itemKeyAtIndex:index]];
}

- (MHVItem *)getLocalItemWithKey:(MHVItemKey *)key
{
    MHVItem *item = [m_store.data getLocalItemWithKey:key];

    if (item && m_enforceTypeCheck)
    {
        if (![item isType:m_typeID])
        {
            item = nil;
        }
    }

    return item;
}

- (void)removeLocalItemAtIndex:(NSUInteger)index
{
    return [m_store.data removeLocalItemWithKey:[self itemKeyAtIndex:index]];
}

- (void)removeAllLocalItems
{
    @autoreleasepool
    {
        for (NSUInteger i = 0, count = m_items.count; i < count; ++i)
        {
            [self removeLocalItemAtIndex:i];
        }
    }
}

- (MHVItem *)getItemAtIndex:(NSUInteger)index
{
    return [self getItemAtIndex:index readAheadCount:m_readAheadChunkSize];
}

- (MHVItem *)getItemByID:(NSString *)itemID
{
    NSUInteger index = [self indexOfItemID:itemID];

    if (index == NSNotFound)
    {
        return nil;
    }

    return [self getItemAtIndex:index];
}

- (MHVItem *)getItemAtIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    if (readAheadCount == 0)
    {
        readAheadCount = c_hvTypeViewDefaultReadAheadChunkSize;
    }

    MHVTypeViewItem *key = [m_items objectAtIndex:index];
    MHVCHECK_NOTNULL(key);

    if (key.isLoadPending)
    {
        return nil; // Will be delivered via delegate
    }

    //
    // Check if we already have this item
    //
    MHVItem *item = [self getLocalItemWithKey:key];
    if (item)
    {
        return item;
    }

    //
    // Find the items we don't already have cached, and start loading them
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

    MHVItemCollection *items = [self getItemsInRange:range nullIfNotFound:FALSE];
    //
    // In case one showed up while we were working
    //
    if (![MHVCollection isNilOrEmpty:items])
    {
        return [items objectAtIndex:0];
    }

   LError:
    return nil;
}

- (MHVItemCollection *)getItemsInRange:(NSRange)range
{
    return [self getItemsInRange:range downloadTask:nil];
}

- (MHVItemCollection *)getItemsInRange:(NSRange)range downloadTask:(MHVTask **)task
{
    return [self getItemsInRange:range nullIfNotFound:TRUE downloadTask:task];
}

- (MHVItemCollection *)getItemsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull
{
    return [self getItemsInRange:range nullIfNotFound:includeNull downloadTask:nil];
}

- (MHVItemCollection *)getItemsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull downloadTask:(MHVTask **)task
{
    range = [m_items correctRange:range];
    if (range.length == 0)
    {
        return nil;
    }

    if (task)
    {
        *task = nil;
    }

    MHVItemKeyCollection *pendingKeys = nil;
    //
    // Fetch local items
    //
    MHVItemCollection *items = [self getLocalItemsInRange:range andPendingList:&pendingKeys nullForNotFound:includeNull];
    //
    // Download any pending items...
    //
    if (![MHVCollection isNilOrEmpty:pendingKeys])
    {
        MHVTask *downloadTask = [self downloadItemsWithKeys:pendingKeys];
        if (task)
        {
            *task = downloadTask;
        }
    }

    return items;
}

- (MHVItemKeyCollection *)keysOfItemsNeedingDownloadInRange:(NSRange)range
{
    MHVItemKeyCollection *pendingKeys = nil;

    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVItem *item = [self getLocalItemAtIndex:i];
        if (!item)
        {
            if (!pendingKeys)
            {
                pendingKeys = [MHVItemKeyCollection new];
                MHVCHECK_NOTNULL(pendingKeys);
            }

            MHVTypeViewItem *key = [m_items objectAtIndex:i];
            [pendingKeys addObject:key];
        }
    }

    return pendingKeys;

   LError:
    return nil;
}

- (MHVTask *)ensureItemsDownloadedInRange:(NSRange)range withCallback:(MHVTaskCompletion)callback
{
    MHVItemKeyCollection *pendingKeys = [self keysOfItemsNeedingDownloadInRange:range];

    if ([MHVCollection isNilOrEmpty:pendingKeys])
    {
        return nil;
    }

    MHVTask *task = [m_store.data newDownloadItemsInRecord:m_store.record forKeys:pendingKeys callback:callback];
    if (!task)
    {
        return nil;
    }

    task.shouldCompleteInMainThread = TRUE;
    [task start];

    return task;
}

- (NSUInteger)putItem:(MHVItem *)item
{
    //
    // First, place in the persistent store
    //
    if (![m_store.data putLocalItem:item])
    {
        return NSNotFound;
    }

    NSUInteger index = [m_items insertHVItemInOrder:item];

    [self stampUpdated];

    return index;
}

- (BOOL)putItems:(MHVItemCollection *)items
{
    MHVCHECK_NOTNULL(items);

    for (MHVItem *item in items)
    {
        [self putItem:item];
    }

    [self stampUpdated];

    return TRUE;

   LError:
    return FALSE;
}

- (BOOL)removeItemAtIndex:(NSUInteger)index
{
    [self removeLocalItemAtIndex:index];
    [m_items removeItemAtIndex:index];
    [self stampUpdated];
    return TRUE;
}

- (NSUInteger)updateItemInView:(MHVItem *)item prevIndex:(NSUInteger *)prevIndex
{
    NSUInteger indexAt = [m_items indexOfItemID:item.itemID];

    if (prevIndex)
    {
        *prevIndex = indexAt;
    }

    NSUInteger newIndex;
    if (indexAt != NSNotFound)
    {
        [m_items removeItemAtIndex:indexAt];
    }

    newIndex = [m_items insertHVItemInOrder:item];

    [self stampUpdated];

    return newIndex;
}

- (NSUInteger)updateItemInView:(MHVItem *)item
{
    return [self updateItemInView:item prevIndex:nil];
}

- (BOOL)removeItemFromViewByID:(NSString *)itemID
{
    if ([m_items removeItemByID:itemID] == NSNotFound)
    {
        return FALSE;
    }

    [self stampUpdated];
    return TRUE;
}

- (BOOL)removeItemsFromViewByID:(NSArray *)itemIDs
{
    if ([NSArray isNilOrEmpty:itemIDs])
    {
        return FALSE;
    }

    BOOL changed = FALSE;
    for (NSString *itemID in itemIDs)
    {
        if ([m_items removeItemByID:itemID] != NSNotFound)
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
    MHVGetItemsTask *getItems = [self newRefreshTask];

    MHVCHECK_NOTNULL(getItems);

    [getItems start];

    return getItems;

   LError:
    return nil;
}

- (MHVTask *)refreshWithCallback:(MHVTaskCompletion)callback
{
    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];

    MHVCHECK_NOTNULL(task);

    MHVGetItemsTask *syncTask = [self newRefreshTask];
    MHVCHECK_NOTNULL(syncTask);

    [task setNextTask:syncTask];

    [task start];
    return task;

   LError:
    return nil;
}

- (MHVItemQuery *)getQuery
{
    return [self newRefreshQuery];
}

- (BOOL)replaceKeys:(MHVTypeViewItems *)items
{
    MHVCHECK_NOTNULL(items);

    [self updateViewWith:items];
    [self notifySynchronized];

    return TRUE;

   LError:
    return FALSE;
}

- (MHVTask *)synchronizeData
{
    return [self synchronizeDataInRange:NSMakeRange(0, m_items.count)];
}

- (MHVTask *)synchronizeDataInRange:(NSRange)range
{
    range = [m_items correctRange:range];
    return [m_store.data downloadItemsWithKeys:[m_items keysInRange:range] inView:self];
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

- (void)updateViewWith:(MHVTypeViewItems *)items
{
    m_items = nil;
    m_items = items;
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

- (void)itemsRetrieved:(MHVItemCollection *)items forKeys:(MHVItemKeyCollection *)keys
{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:2];

    [params addObject:items];
    [params addObject:keys];

    [self invokeOnMainThread:@selector(processItemsRetrieved:) withObject:params];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_typeID value:m_typeID];
    [writer writeElement:c_element_filter content:m_filter];
    [writer writeElement:c_element_updateDate dateValue:m_lastUpdateDate];
    [writer writeElement:c_element_items content:m_items];
    [writer writeElement:c_element_chunkSize intValue:(int)m_readAheadChunkSize];
    [writer writeElement:c_element_maxItems intValue:(int)m_maxItems];
}

- (void)deserialize:(XReader *)reader
{
    m_typeID = [reader readStringElement:c_element_typeID];
    m_filter = [reader readElement:c_element_filter asClass:[MHVItemFilter class]];
    m_lastUpdateDate = [reader readDateElement:c_element_updateDate];
    m_items = [reader readElement:c_element_items asClass:[MHVTypeViewItems class]];
    m_readAheadChunkSize = [reader readIntElement:c_element_chunkSize];
    if (m_readAheadChunkSize <= 0)
    {
        m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    }

    m_maxItems = [reader readIntElement:c_element_maxItems];
}

- (MHVTypeView *)subviewForRange:(NSRange)range
{
    MHVTypeViewItems *subItems = [[MHVTypeViewItems alloc] init];

    if (m_items)
    {
        [m_items correctRange:range];
        for (NSUInteger i = 0, max = NSMaxRange(range); i < max; ++i)
        {
            [subItems addObject:[m_items objectAtIndex:i]];
        }
    }

    return [[MHVTypeView alloc] initFromTypeView:self andItems:subItems];
}

- (void)setTypeID:(NSString *)typeID
{
    m_typeID = typeID;
}

- (void)setFilter:(MHVTypeFilter *)filter
{
    m_filter = filter;
}

- (void)setItems:(MHVTypeViewItems *)items
{
    m_items = items;
}

- (MHVItemQuery *)newRefreshQuery
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithTypeID:m_typeID];

    MHVCHECK_NOTNULL(query);

    query.view.sections = MHVItemSection_Core;
    if (m_filter)
    {
        [query.filters addObject:m_filter];
    }

    if (m_maxItems > 0)
    {
        query.maxResults = (int)m_maxItems;
    }

    query.maxFullResults = 0;
    return query;

   LError:
    return nil;
}

- (MHVGetItemsTask *)newRefreshTask
{
    MHVItemQuery *query = [self newRefreshQuery];

    MHVCHECK_NOTNULL(query);

    MHVGetItemsTask *getItems = [[MHVClient current].methodFactory newGetItemsForRecord:self.record query:query andCallback:^(MHVTask *task) {
        if (![NSThread isMainThread])
        {
            [self invokeOnMainThread:@selector(synchronizeViewCompleted:) withObject:task];
        }
        else
        {
            [self synchronizeViewCompleted:task];
        }
    }];
    getItems.shouldCompleteInMainThread = TRUE;

    return getItems;

   LError:
    return nil;
}

//
// This MUST always be called in the main UI thread
//
- (void)synchronizeViewCompleted:(MHVTask *)task
{
    MHVTypeViewItems *newViewItems = [[MHVTypeViewItems alloc] init];

    @try
    {
        MHVItemQueryResults *results = task.result;

        if (results.hasResults)
        {
            MHVItemQueryResult *result = results.firstResult;
            if (![newViewItems addQueryResult:result])
            {
                [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_Sync)];
            }
        }

        self.items = newViewItems;

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
        newViewItems = nil;
    }
}

- (NSRange)getChunkForIndex:(NSUInteger)index chunkSize:(NSUInteger)chunkSize
{
    NSUInteger chunk = index / chunkSize;
    NSUInteger chunkStartAt = chunk * chunkSize;
    NSRange range = [m_items correctRange:NSMakeRange(chunkStartAt, chunkSize)];

    return range;
}

- (NSRange)getReadAheadRangeForIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    return [m_items correctRange:NSMakeRange(index, readAheadCount)];
}

- (MHVItemCollection *)getLocalItemsInRange:(NSRange)range andPendingList:(MHVItemKeyCollection **)pending nullForNotFound:(BOOL)includeNull
{
    *pending = nil;

    MHVItemKeyCollection *pendingKeys = nil;
    MHVItemCollection *items = [[MHVItemCollection alloc] initWithCapacity:range.length];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVTypeViewItem *key = [m_items objectAtIndex:i];
        MHVItem *item = [self getLocalItemWithKey:key];
        if (item)
        {
            [items addObject:item];
        }
        else
        {
            if (!pendingKeys)
            {
                pendingKeys = [MHVItemKeyCollection new];
                MHVCHECK_NOTNULL(pendingKeys);
            }

            [pendingKeys addObject:key];

            if (includeNull)
            {
                [items addObject:(MHVItem *)[NSNull null]];
            }
        }
    }

    *pending = pendingKeys;
    return items;

   LError:
    return nil;
}

- (MHVTask *)downloadItemsWithKeys:(MHVItemKeyCollection *)keys
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
    MHVTask *task = [m_store.data downloadItemsWithKeys:keys typeID:m_typeID inView:self];
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
- (void)prepareKeysForLoading:(MHVItemKeyCollection *)keys
{
    NSUInteger i = 0;
    NSUInteger count = keys.count;

    while (i < count)
    {
        MHVTypeViewItem *key = (MHVTypeViewItem *)[keys objectAtIndex:i];
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

- (BOOL)updateItemsInView:(MHVItemCollection *)items
{
    if ([MHVCollection isNilOrEmpty:items])
    {
        return FALSE;
    }

    BOOL changed = FALSE;
    for (NSUInteger i = 0, count = items.count; i < count; ++i)
    {
        if ([m_items updateMHVItem:[items objectAtIndex:i]])
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

- (BOOL)removeItemsForKeys:(MHVItemKeyCollection *)keys
{
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return TRUE;
    }

    @try
    {
        for (NSUInteger i = 0, count = keys.count; i < count; ++i)
        {
            MHVItemKey *key = [keys objectAtIndex:i];

            [m_store.data removeLocalItemWithKey:key];
            [m_items removeItemByID:key.itemID];
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
- (void)processItemsRetrieved:(NSArray *)params
{
    MHVItemCollection *items = [params objectAtIndex:0];
    MHVItemKeyCollection *keys = [params objectAtIndex:1];

    if (items && items.count > 0)
    {
        [self itemsAvailableInStore:items];
    }

    //
    // Not all keys may have resulted in items being retrieved
    //
    MHVItemKeyCollection *keysNotFound = [self selectKeys:keys notIn:items];
    if (![MHVCollection isNilOrEmpty:keysNotFound])
    {
        [self keysNotAvailableInStore:keysNotFound];
    }
}

- (MHVItemKeyCollection *)selectKeys:(MHVItemKeyCollection *)keys notIn:(MHVItemCollection *)items
{
    if (items.count >= keys.count)
    {
        return nil;
    }

    NSMutableDictionary *itemsByID = [items newIndexByID];
    if (!itemsByID)
    {
        return nil;
    }

    MHVItemKeyCollection *keysNotFound = [MHVItemKeyCollection new];
    for (MHVItemKey *key in keys)
    {
        if (![itemsByID objectForKey:key.itemID])
        {
            [keysNotFound addObject:key];
        }
    }

    return keysNotFound;
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)itemsAvailableInStore:(MHVItemCollection *)items
{
    [self setDownloadStatus:FALSE forItems:items];

    BOOL viewChanged = [self updateItemsInView:items];

    [self notifyItemsAvailable:items viewChanged:viewChanged];
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
- (void)keysNotAvailableInStore:(MHVItemKeyCollection *)keys
{
    if ([MHVCollection isNilOrEmpty:keys])
    {
        return;
    }

    //
    // Let the view clean itself up
    //
    [self removeItemsForKeys:keys];
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
    MHVItemKeyCollection *keys = [params objectAtIndex:0];
    id error = [params objectAtIndex:1];

    [self setDownloadStatus:FALSE forKeys:keys];
    [self notifySyncFailed:error];
}

- (void)setDownloadStatus:(BOOL)status forIndex:(NSUInteger)index
{
    MHVTypeViewItem *key = [self itemKeyAtIndex:index];

    if (key)
    {
        key.isLoadPending = status;
    }
}

- (void)setDownloadStatus:(BOOL)status forKeys:(MHVItemKeyCollection *)keys
{
    for (MHVTypeViewItem *key in keys)
    {
        key.isLoadPending = status;
    }
}

- (void)setDownloadStatus:(BOOL)status forItems:(MHVItemCollection *)items
{
    for (MHVItem *item in items)
    {
        MHVTypeViewItem *key = [m_items objectForItemID:item.itemID];
        if (key)
        {
            key.isLoadPending = status;
        }
    }
}

- (void)notifyItemsAvailable:(MHVItemCollection *)items viewChanged:(BOOL)viewChanged
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate itemsAvailable:items inView:self viewChanged:viewChanged];
        }
    });
}

- (void)notifyKeysNotAvailable:(MHVItemKeyCollection *)keys
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
