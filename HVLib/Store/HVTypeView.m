//
//  HVTypeView.m
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

#import "HVCommon.h"
#import "HVTypeView.h"
#import "HVSynchronizedStore.h"
#import "HVClientException.h"
#import "HVBlock.h"
#import "HVClient.h"

static NSString* const c_element_typeID = @"typeID";
static NSString* const c_element_filter = @"filter";
static NSString* const c_element_updateDate = @"updateDate";
static NSString* const c_element_items = @"items";
static NSString* const c_element_chunkSize = @"chunkSize";
static NSString* const c_element_maxItems = @"maxItems";

const int c_hvTypeViewDefaultReadAheadChunkSize = 50;

@interface HVTypeView (HVPrivate)

-(void) setTypeID:(NSString *) typeID;
-(void) setFilter:(HVTypeFilter *) filter;
-(void) setItems:(HVTypeViewItems *) items;

-(NSRange) getChunkForIndex:(NSUInteger) index chunkSize:(NSUInteger) chunkSize;
-(NSRange) getReadAheadRangeForIndex:(NSUInteger) index readAheadCount:(NSUInteger) readAheadCount;
-(HVItemCollection *) getLocalItemsInRange:(NSRange) range andPendingList:(NSMutableArray **) pending nullForNotFound:(BOOL)includeNull;
-(HVTask *) downloadItemsWithKeys:(NSMutableArray *) keys;

-(BOOL) updateItemsInView:(HVItemCollection *) items;
-(BOOL) removeItemsForKeys:(NSArray *) keys;

-(void) setDownloadStatus:(BOOL) status forIndex:(NSUInteger) index;
-(void) setDownloadStatus:(BOOL) status forKeys:(NSArray *) keys;
-(void) setDownloadStatus:(BOOL)status forItems:(NSArray *) items;

-(HVItemQuery *) newRefreshQuery;
-(HVGetItemsTask *) newRefreshTask;
-(void) synchronizeViewCompleted:(HVTask *) task;
-(void) stampUpdated;

-(void) prepareKeysForLoading:(NSMutableArray *) keys;
//
// SynchronizedStore calls itemsRetrieved, which invokes this in the main thread
//
-(void) processItemsRetrieved:(NSArray *) params;
-(NSMutableArray *) selectKeys:(NSArray *) keys notIn:(HVItemCollection *) items;

-(void) itemsAvailableInStore:(HVItemCollection *) items;
-(void) keysNotAvailableInStore:(NSArray *) keys;
-(void) keysFailed:(NSArray *) params;

-(void) notifyItemsAvailable:(HVItemCollection *)items viewChanged:(BOOL) viewChanged;
-(void) notifyKeysNotAvailable:(NSArray *) keys;

-(void) notifySynchronized;
-(void) notifySyncFailed:(id) error;

@end

@implementation HVTypeView

@synthesize typeID = m_typeID;
@synthesize filter = m_filter;
@synthesize lastUpdateDate = m_lastUpdateDate;
@synthesize maxItems = m_maxItems;
@synthesize store = m_store;
@synthesize delegate = m_delegate;
@synthesize tag = m_tag;
-(BOOL)readAheadModeChunky
{
    return (m_readAheadMode == HVTypeViewReadAheadModePage);
}
-(void)setReadAheadModeChunky:(BOOL)readAheadModeChunky
{
    if (readAheadModeChunky)
    {
        m_readAheadMode = HVTypeViewReadAheadModePage;
    }
    else
    {
        m_readAheadMode = HVTypeViewReadAheadModeSequential;
    }
}

@synthesize readAheadMode = m_readAheadMode;

-(NSInteger)readAheadChunkSize
{
    return m_readAheadChunkSize;
}
-(void)setReadAheadChunkSize:(NSInteger)readAheadChunkSize
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

-(HVRecordReference *)record
{
    return m_store.record;
}

-(NSDate *) lastUpdateDate
{
    if (!m_lastUpdateDate)
    {
        [self stampUpdated];
    }
    
    return m_lastUpdateDate;
}

-(void)setLastUpdateDate:(NSDate *)lastUpdateDate
{
    HVRETAIN(m_lastUpdateDate, lastUpdateDate);
}

-(void)setStore:(HVLocalRecordStore *)store
{
    HVASSERT(store);
    HVRETAIN(m_store, store);
}

-(NSUInteger)count
{
    return m_items.count;
}

-(NSDate *)minDate
{
    return m_items.minDate;
}

-(NSDate *)maxDate
{
    return m_items.maxDate;
}

// We need a default vanilla constructor for Xml serialization
-(id) init
{
    return [super init];
}

-(id)initForTypeID:(NSString *)typeID overStore:(HVLocalRecordStore *)store
{
    return [self initForTypeID:typeID filter:nil overStore:store];
}

-(id)initForTypeID:(NSString *)typeID filter:(HVTypeFilter *)filter overStore:(HVLocalRecordStore *)store
{
    return [self initForTypeID:typeID filter:filter items:nil overStore:store];
}

-(id)initForTypeID:(NSString *)typeID filter:(HVTypeFilter *)filter items:(HVTypeViewItems *)items overStore:(HVLocalRecordStore *)store
{
    HVCHECK_NOTNULL(typeID);
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.typeID = typeID;
    self.filter = filter;
    self.store = store;
    m_readAheadMode = HVTypeViewReadAheadModePage;
    m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    self.enforceTypeCheck = FALSE;
    if (items)
    {
        HVRETAIN(m_items, items);
    }
    else
    {
        m_items = [[HVTypeViewItems alloc] init];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;    
}

-(id)initFromTypeView:(HVTypeView *)typeView andItems:(HVTypeViewItems *)items
{
    HVCHECK_NOTNULL(typeView);
    
    self = [self initForTypeID:typeView.typeID filter:typeView.filter items:items overStore:typeView.store];
    HVCHECK_SELF;
    
    m_readAheadMode = typeView.readAheadMode;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_typeID release];
    [m_filter release];
    [m_lastUpdateDate release];
    [m_items release];
    [m_store release];
    
    [super dealloc];
}

-(HVItemKey *)keyAtIndex:(NSUInteger)index
{
    return [self itemKeyAtIndex:index];
}

-(HVTypeViewItem *)itemKeyAtIndex:(NSUInteger)index
{
    return [m_items objectAtIndex:index];
}

-(NSUInteger)indexOfItemID:(NSString *)itemID
{
    return [m_items indexOfItemID:itemID];
}

-(void) removeKeyAtIndex:(NSUInteger)index
{
    [m_items removeItemAtIndex:index];
}

-(NSUInteger)insertKeyForItem:(HVItem *)item
{
    return [m_items insertHVItemInOrder:item];
}

-(BOOL)updateKeyForItem:(HVItem *)item
{
    return [m_items updateHVItem:item];
}

-(NSUInteger)indexOfItemWithClosestDate:(NSDate *)date
{
    return [self indexOfItemWithClosestDate:date firstEqual:TRUE];
}

-(NSUInteger)indexOfItemWithClosestDate:(NSDate *)date firstEqual:(BOOL)firstEqual
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
        
        HVTypeViewItem* item;
        NSComparisonResult cmp;
        if (date == o1)
        {
            item = (HVTypeViewItem *) o2;
            cmp = [date compareDescending:item.date];
        }
        else
        {
            item = (HVTypeViewItem *) o1;
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

-(NSUInteger)indexOfFirstDay:(NSDate *)date
{
    NSDate* day = [date toStartOfDay];
    NSUInteger index = [self indexOfItemWithClosestDate:day];
    if (index == NSNotFound)
    {
        return index;
    }
    
    return [self indexOfFirstDay:date startAt:index];
}

-(NSUInteger)indexOfFirstDay:(NSDate *)date startAt:(NSUInteger)baseIndex
{
    NSUInteger index = baseIndex;
    
    NSCalendar* calendar = [[NSCalendar newGregorian] autorelease];
    NSDateComponents* baseComponents = [calendar getComponentsFor:date];
    
    for (; index > 0; --index)
    {
        NSDateComponents* itemComponents = [calendar getComponentsFor:[self itemKeyAtIndex:index].date];
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

-(BOOL)containsItemID:(NSString *)itemID
{
    return ([self indexOfItemID:itemID] != NSNotFound);
}

-(HVTypeViewItem *)itemForItemID:(NSString *)itemID
{
    NSUInteger index = [self indexOfItemID:itemID];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self itemKeyAtIndex:index];
}

-(HVItem *)getLocalItemAtIndex:(NSUInteger)index
{
    return [self getLocalItemWithKey:[self itemKeyAtIndex:index]];
}

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
{
    HVItem* item = [m_store.data getLocalItemWithKey:key];
    if (item && m_enforceTypeCheck)
    {
        if (![item isType:m_typeID])
        {
            item = nil;
        }
    }
    
    return item;
}

-(void)removeLocalItemAtIndex:(NSUInteger)index
{
    return [m_store.data removeLocalItemWithKey:[self itemKeyAtIndex:index]];
}

-(void)removeAllLocalItems
{
    @autoreleasepool
    {
        for (NSUInteger i = 0, count = m_items.count; i < count; ++i)
        {
            [self removeLocalItemAtIndex:i];
        }
    }
}

-(HVItem *)getItemAtIndex:(NSUInteger)index
{
    return [self getItemAtIndex:index readAheadCount:m_readAheadChunkSize];
}

-(HVItem *)getItemByID:(NSString *)itemID
{
    NSUInteger index = [self indexOfItemID:itemID];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self getItemAtIndex:index];
}

-(HVItem *)getItemAtIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    if (readAheadCount == 0)
    {
        readAheadCount = c_hvTypeViewDefaultReadAheadChunkSize;
    }
    
    HVTypeViewItem* key = [m_items objectAtIndex:index];
    HVCHECK_NOTNULL(key);
    
    if (key.isLoadPending)
    {
        return nil; // Will be delivered via delegate
    }
    //
    // Check if we already have this item
    //
    HVItem* item = [self getLocalItemWithKey:key];
    if (item)
    {
        return item;
    }
    //
    // Find the items we don't already have cached, and start loading them
    //
    NSRange range;
    if (m_readAheadMode == HVTypeViewReadAheadModePage)
    {
        range = [self getChunkForIndex:index chunkSize:readAheadCount];
    }
    else
    {
        range = [self getReadAheadRangeForIndex:index readAheadCount:readAheadCount];
    }

    HVItemCollection* items = [self getItemsInRange:range nullIfNotFound:FALSE];
    //
    // In case one showed up while we were working
    //
    if (![NSArray isNilOrEmpty:items])
    {
        return [items objectAtIndex:0];
    }
    
LError:
    return nil;
}

-(HVItemCollection *) getItemsInRange:(NSRange) range
{
    return [self getItemsInRange:range downloadTask:nil];
}

-(HVItemCollection *)getItemsInRange:(NSRange)range downloadTask:(HVTask **)task
{
    return [self getItemsInRange:range nullIfNotFound:TRUE downloadTask:task];
}

-(HVItemCollection *)getItemsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull
{
    return [self getItemsInRange:range nullIfNotFound:includeNull downloadTask:nil];
}

-(HVItemCollection *)getItemsInRange:(NSRange)range nullIfNotFound:(BOOL)includeNull downloadTask:(HVTask **)task
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
    
    NSMutableArray* pendingKeys = nil;
    //
    // Fetch local items
    //
    HVItemCollection* items = [self getLocalItemsInRange:range andPendingList:&pendingKeys nullForNotFound:includeNull];
    //
    // Download any pending items...
    //
    if (![NSArray isNilOrEmpty:pendingKeys])
    {
        HVTask* downloadTask = [self downloadItemsWithKeys:pendingKeys];
        if (task)
        {
            *task = downloadTask;
        }
    }
    
    return items;    
}

-(NSArray *)keysOfItemsNeedingDownloadInRange:(NSRange)range
{
    NSMutableArray* pendingKeys = nil;
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        HVItem* item = [self getLocalItemAtIndex:i];
        if (!item)
        {
            if (!pendingKeys)
            {
                pendingKeys = [[[NSMutableArray alloc]init] autorelease];
                HVCHECK_NOTNULL(pendingKeys);
            }
            HVTypeViewItem* key = [m_items objectAtIndex:i];
            [pendingKeys addObject:key];
        }
    }
    
    return pendingKeys;
    
LError:
    return nil;
    
}

-(HVTask *)ensureItemsDownloadedInRange:(NSRange)range withCallback:(HVTaskCompletion)callback
{
    NSArray* pendingKeys = [self keysOfItemsNeedingDownloadInRange:range];
    if ([NSArray isNilOrEmpty:pendingKeys])
    {
        return nil;
    }
    
    HVTask* task = [[m_store.data newDownloadItemsInRecord:m_store.record forKeys:pendingKeys callback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    task.shouldCompleteInMainThread = TRUE;
    [task start];
    
    return task;
    
LError:
    return task;
}

-(NSUInteger)putItem:(HVItem *)item
{
    //
    // First, place in the persistent store
    //
    HVCHECK_SUCCESS([m_store.data putLocalItem:item]);
    
    NSUInteger index = [m_items insertHVItemInOrder:item];
    
    [self stampUpdated];
    
    return index;   

LError:
    return NSNotFound;
}

-(BOOL)putItems:(HVItemCollection *)items
{
    HVCHECK_NOTNULL(items);
    
    for (HVItem* item in items)
    {
        [self putItem:item];
    }
    
    [self stampUpdated];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)removeItemAtIndex:(NSUInteger)index
{
    [self removeLocalItemAtIndex:index];
    [m_items removeItemAtIndex:index];
    [self stampUpdated];
    return TRUE;
}

-(NSUInteger)updateItemInView:(HVItem *)item prevIndex:(NSUInteger *)prevIndex
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

-(NSUInteger)updateItemInView:(HVItem *)item
{
    return [self updateItemInView:item prevIndex:nil];
}

-(BOOL)removeItemFromViewByID:(NSString *)itemID
{
    if ([m_items removeItemByID:itemID] == NSNotFound)
    {
        return FALSE;
    }
    
    [self stampUpdated];
    return TRUE;
}

-(BOOL)removeItemsFromViewByID:(NSArray *)itemIDs
{
    if ([NSArray isNilOrEmpty:itemIDs])
    {
        return FALSE;
    }
    
    BOOL changed = FALSE;
    for (NSString* itemID in itemIDs) 
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

-(BOOL)isStale:(NSTimeInterval) maxAge
{
    if (!m_lastUpdateDate)
    {
        return TRUE;
    }
    
    NSDate* now = [NSDate date];
    return ([now timeIntervalSinceDate:m_lastUpdateDate] > maxAge);
}

-(HVTask *)synchronize
{
    return [self refresh];
}

-(HVTask *)refresh
{
    HVGetItemsTask* getItems = [[self newRefreshTask] autorelease];
    HVCHECK_NOTNULL(getItems);
    
    [getItems start];
    
    return getItems;

LError:
    return nil;
}

-(HVTask *)refreshWithCallback:(HVTaskCompletion)callback
{
    HVTask* task = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    HVGetItemsTask* syncTask = [self newRefreshTask];
    HVCHECK_NOTNULL(syncTask);
    
    [task setNextTask:syncTask];
    [syncTask release];
    
    [task start];
    return task;
    
LError:
    return nil;
}

-(HVItemQuery *)getQuery
{
    return [[self newRefreshQuery] autorelease];
}

-(BOOL)replaceKeys:(HVTypeViewItems *)items
{
    HVCHECK_NOTNULL(items);
    
    [self updateViewWith:items];
    [self notifySynchronized];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(HVTask *)synchronizeData
{
    return [self synchronizeDataInRange:NSMakeRange(0, m_items.count)];
}

-(HVTask *)synchronizeDataInRange:(NSRange)range
{
    range = [m_items correctRange:range];
    return [m_store.data downloadItemsWithKeys:[m_items selectRange:range] inView:self];
}

-(BOOL)save
{
    return [self saveWithName:self.typeID];
}

-(BOOL)saveWithName:(NSString *)name
{
    return [m_store putView:self name:name];
}

+(HVTypeView *)loadViewNamed:(NSString *)name fromStore:(HVLocalRecordStore *)store
{
    return [store getView:name];
}

+(HVTypeView *)getViewForTypeClassName:(NSString *)className inRecord:(HVRecordReference *)record
{
    NSString *typeID = [[HVTypeSystem current] getTypeIDForClassName:className]; 
    return [HVTypeView getViewForTypeID:typeID inRecord:record];
}

+(HVTypeView *)getViewForTypeID:(NSString *)typeID inRecord:(HVRecordReference *)record
{
    HVLocalRecordStore* recordStore = [[HVClient current].localVault getRecordStore:record];
    return [HVTypeView getViewForTypeID:typeID andRecordStore:recordStore];
}

+(HVTypeView *)getViewForTypeID:(NSString *)typeID andRecordStore:(HVLocalRecordStore *)store
{
    HVCHECK_NOTNULL(store);
    
    HVTypeView *view = [HVTypeView loadViewNamed:typeID fromStore:store];
    if (!view)
    {
        view = [[[HVTypeView alloc] initForTypeID:typeID overStore:store] autorelease];
    }
    
    return view;
    
LError:
    return nil;
}

-(void)updateViewWith:(HVTypeViewItems *)items
{
    HVCLEAR(m_items);
    HVRETAIN(m_items, items);
    [self stampUpdated];
}

//-------------------------
//
// Called by SynchronizedStore.
// These can come in on any thread. We can do local computation, but
// we must push all changes we need to make to TypeView - to the Main thread
//
//------------------------
-(void)keysNotRetrieved:(NSArray *)keys withError:(id)error
{
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:2];
    [params addObject:keys];
    [params addObject:error];
    
    [self invokeOnMainThread:@selector(keysFailed:) withObject:params];
    [params release];
}

-(void)itemsRetrieved:(HVItemCollection *)items forKeys:(NSArray *)keys
{
    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:2];
    [params addObject:items];
    [params addObject:keys];
    
    [self invokeOnMainThread:@selector(processItemsRetrieved:) withObject:params];
    [params release];
}


-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_typeID, c_element_typeID);
    HVSERIALIZE(m_filter, c_element_filter);
    HVSERIALIZE_DATE(m_lastUpdateDate, c_element_updateDate);
    HVSERIALIZE(m_items, c_element_items);
    HVSERIALIZE_INT((int)m_readAheadChunkSize, c_element_chunkSize);
    HVSERIALIZE_INT((int)m_maxItems, c_element_maxItems);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_typeID, c_element_typeID);
    HVDESERIALIZE(m_filter, c_element_filter, HVItemFilter);
    HVDESERIALIZE_DATE(m_lastUpdateDate, c_element_updateDate);
    HVDESERIALIZE(m_items, c_element_items, HVTypeViewItems);
    HVDESERIALIZE_INT(m_readAheadChunkSize, c_element_chunkSize);
    if (m_readAheadChunkSize <= 0)
    {
        m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    }
    HVDESERIALIZE_INT(m_maxItems, c_element_maxItems);
}

-(HVTypeView *)subviewForRange:(NSRange)range
{
    HVTypeViewItems* subItems = [[[HVTypeViewItems alloc] init] autorelease];
    
    if (m_items)
    {
        [m_items correctRange:range];
        for (NSUInteger i = 0, max = NSMaxRange(range); i < max; ++i)
        {
            [subItems addItem:[m_items objectAtIndex:i]];
        }
    }
    
    return [[[HVTypeView alloc] initFromTypeView:self andItems:subItems] autorelease];
}

@end

//----------------
//
// PRIVATE
//
//----------------
@implementation HVTypeView (HVPrivate)

-(void)setTypeID:(NSString *)typeID
{
    HVRETAIN(m_typeID, typeID);
}

-(void)setFilter:(HVTypeFilter *)filter
{
    HVRETAIN(m_filter, filter);
}

-(void)setItems:(HVTypeViewItems *)items
{
    HVRETAIN(m_items, items);
}

-(HVItemQuery *)newRefreshQuery
{
    HVItemQuery* query = [[HVItemQuery alloc] initWithTypeID:m_typeID];
    HVCHECK_NOTNULL(query);
    
    query.view.sections = HVItemSection_Core;
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

-(HVGetItemsTask *)newRefreshTask
{
    HVItemQuery* query = [self newRefreshQuery];
    HVCHECK_NOTNULL(query);
    
    HVGetItemsTask* getItems = [[HVClient current].methodFactory newGetItemsForRecord:self.record query:query andCallback:^(HVTask *task) {
        
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
    [query release];
    
    return getItems;

LError:
    return nil;
}

//
// This MUST always be called in the main UI thread
//
-(void)synchronizeViewCompleted:(HVTask *)task
{
    HVTypeViewItems* newViewItems = [[HVTypeViewItems alloc] init];
    @try 
    {
        HVItemQueryResults* results = task.result;

        if (results.hasResults)
        {
            HVItemQueryResult* result = results.firstResult;
            if (![newViewItems addQueryResult:result])
            {
                [HVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_Sync)];
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
        [newViewItems release];
    }
}

-(NSRange)getChunkForIndex:(NSUInteger)index chunkSize:(NSUInteger)chunkSize
{
    NSUInteger chunk = index / chunkSize;
    NSUInteger chunkStartAt = chunk * chunkSize;
    NSRange range = [m_items correctRange:NSMakeRange(chunkStartAt, chunkSize)];
    return range;
}

-(NSRange)getReadAheadRangeForIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    return [m_items correctRange:NSMakeRange(index, readAheadCount)];
}

-(HVItemCollection *)getLocalItemsInRange:(NSRange)range andPendingList:(NSMutableArray **)pending nullForNotFound:(BOOL)includeNull
{
    *pending = nil;
    
    NSMutableArray* pendingKeys = nil;
    HVItemCollection* items = [[[HVItemCollection alloc] initWithCapacity:range.length] autorelease];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        HVTypeViewItem* key = [m_items objectAtIndex:i];
        HVItem* item = [self getLocalItemWithKey:key];
        if (item)
        {
            [items addObject:item];
        }
        else
        {
            if (!pendingKeys)
            {
                pendingKeys = [[[NSMutableArray alloc]init] autorelease];
                HVCHECK_NOTNULL(pendingKeys);
            }
            [pendingKeys addObject:key];
            
            if (includeNull)
            {
                [items addObject:[NSNull null]];
            }
        }
    }
    
    *pending = pendingKeys;
    return items;
    
LError:
    return nil;
}

-(HVTask *) downloadItemsWithKeys:(NSMutableArray *)keys
{   
    if ([NSArray isNilOrEmpty:keys])
    {
        return nil;
    }
    //
    // This will remove any keys that have pending loads...
    //
    [self prepareKeysForLoading:keys];
    if ([NSArray isNilOrEmpty:keys])
    {
        return nil;
    }
    //
    // Launch the download task
    //
    HVTask* task = [m_store.data downloadItemsWithKeys:keys typeID:m_typeID inView:self];
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
-(void)prepareKeysForLoading:(NSMutableArray *)keys
{
    NSUInteger i = 0;
    NSUInteger count = keys.count;
    while (i < count)
    {
        HVTypeViewItem* key = [keys objectAtIndex:i];
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

-(BOOL) updateItemsInView:(HVItemCollection *)items
{
    if ([NSArray isNilOrEmpty:items])
    {
        return FALSE;
    }
    
    BOOL changed = FALSE;
    for (NSUInteger i = 0, count = items.count; i < count; ++i)
    {
        if ([m_items updateHVItem:[items objectAtIndex:i]])
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

-(BOOL)removeItemsForKeys:(NSArray *)keys
{
    if ([NSArray isNilOrEmpty:keys])
    {
        return TRUE;
    }
    
    @try
    {
        for (NSUInteger i = 0, count = keys.count; i < count; ++i)
        {
            HVItemKey* key = [keys objectAtIndex:i];
            
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
-(void)processItemsRetrieved:(NSArray *) params
{
    HVItemCollection* items = [params objectAtIndex:0];
    NSArray* keys = [params objectAtIndex:1];
    
    if (items && items.count > 0)
    {
        [self itemsAvailableInStore:items];
    }
    //
    // Not all keys may have resulted in items being retrieved
    //
    NSMutableArray* keysNotFound = [self selectKeys:keys notIn:items];
    if (![NSArray isNilOrEmpty:keysNotFound])
    {
        [self keysNotAvailableInStore:keysNotFound];
    }
}

-(NSMutableArray *)selectKeys:(NSArray *)keys notIn:(HVItemCollection *)items
{
    if (items.count >= keys.count)
    {
        return nil;
    }
    
    NSMutableDictionary* itemsByID = [items newIndexByID];
    if (!itemsByID)
    {
        return nil;
    }
    
    NSMutableArray* keysNotFound = [[[NSMutableArray alloc] init] autorelease];
    for (HVItemKey* key in keys)
    {
        if (![itemsByID objectForKey:key.itemID])
        {
            [keysNotFound addObject:key];
        }
    }
    
    [itemsByID release];
    return  keysNotFound;
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
-(void)itemsAvailableInStore:(HVItemCollection *)items
{
    [self setDownloadStatus:FALSE forItems:items];
    
    BOOL viewChanged = [self updateItemsInView:items];
    
    [self notifyItemsAvailable:items viewChanged:viewChanged];
}

//
// MUST ALWAYS BE CALLED IN THE UI THREAD
//
-(void)keysNotAvailableInStore:(NSArray *)keys
{
    if ([NSArray isNilOrEmpty:keys])
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
-(void)keysFailed:(NSArray *)params
{
    NSArray* keys = [params objectAtIndex:0];
    id error = [params objectAtIndex:1];
    
    [self setDownloadStatus:FALSE forKeys:keys]; 
    [self notifySyncFailed:error];
}

-(void)setDownloadStatus:(BOOL)status forIndex:(NSUInteger)index
{
    HVTypeViewItem* key = [self itemKeyAtIndex:index];
    if (key)
    {
        key.isLoadPending = status;
    }    
}

-(void)setDownloadStatus:(BOOL) status forKeys :(NSArray *)keys
{
    for (HVTypeViewItem* key in keys) 
    {
        key.isLoadPending = status;
    }
}

-(void)setDownloadStatus:(BOOL)status forItems:(NSArray *)items
{
    for (HVItem* item in items)
    {
        HVTypeViewItem* key = [m_items objectForItemID:item.itemID];
        if (key)
        {
            key.isLoadPending = status;
        }
    }
}

-(void)notifyItemsAvailable:(HVItemCollection *)items viewChanged:(BOOL)viewChanged
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate itemsAvailable:items inView:self viewChanged:viewChanged];
        }
    });
}

-(void)notifyKeysNotAvailable:(NSArray *)keys
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate keysNotAvailable:keys inView:self];
        }
    });
}

-(void)notifySynchronized
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate synchronizationCompletedInView:self];
        }
    });
}

-(void)notifySyncFailed:(id)error
{
    safeInvokeActionEx(^{
        if (m_delegate)
        {
            [m_delegate synchronizationFailedInView:self withError:error];
        }
    }, TRUE);  // Ensures that delegate is called in UI thread
}

-(void)stampUpdated
{
    self.lastUpdateDate = [NSDate date];
}

@end
