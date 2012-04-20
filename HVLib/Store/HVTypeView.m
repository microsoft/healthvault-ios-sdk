//
//  HVDataView.m
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

@interface HVTypeView (HVPrivate)

-(void) setTypeID:(NSString *) typeID;
-(void) setFilter:(HVTypeFilter *) filter;
-(void) setLastUpdateDate:(NSDate *)lastUpdateDate;
-(void) setStore:(HVLocalRecordStore *) store;
-(void) setItems:(HVTypeViewItems *) items;

-(HVItemCollection *) getLocalItemsInRange:(NSRange) range andPendingList:(NSMutableArray **) pending;
-(HVTask *) downloadItemsWithKeys:(NSMutableArray *) keys;
-(void) setDownloadStatus:(BOOL) status forIndex:(NSUInteger) index;
-(void) setDownloadStatus:(BOOL) status forKeys:(NSArray *) keys;
-(void) setDownloadStatus:(BOOL)status forItems:(NSArray *) items;

-(void) synchronizeViewCompleted:(HVItemQueryResults *) results;
-(void) stampUpdated;

-(void) itemsAvailableInStore:(HVItemCollection *) items;
-(void) keysNotAvailableInStore:(NSArray *) keys;

-(void) notifyItemsAvailable:(HVItemCollection *) items;
-(void) notifyKeysNotAvailable:(NSArray *) keys;

-(void) notifySynchronized:(NSArray *) keysRemoved;
-(void) notifySyncFailed:(id) error;

@end

@implementation HVTypeView

@synthesize typeID = m_typeID;
@synthesize filter = m_filter;
@synthesize lastUpdateDate = m_lastUpdateDate;
@synthesize maxItems = m_maxItems;
@synthesize store = m_store;
@synthesize delegate = m_delegate;

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

-(void)setDelegate:(id<HVTypeViewDelegate>)delegate
{
    @synchronized(self)
    {
        HVRETAIN(m_delegate, delegate);
        if (delegate)
        {
            m_isDelegateInMainThread = [NSThread isMainThread];
        }
        else
        {
            m_isDelegateInMainThread = FALSE;
        }
    }
}

-(NSUInteger)count
{
    return m_items.count;
}

-(id)initForTypeID:(NSString *)typeID overStore:(HVLocalRecordStore *)store
{
    return [self initForTypeID:typeID filter:nil overStore:store];
}

-(id)initForTypeID:(NSString *)typeID filter:(HVTypeFilter *)filter overStore:(HVLocalRecordStore *)store
{
    HVCHECK_NOTNULL(typeID);
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.typeID = typeID;
    self.filter = filter;
    self.store = store;
    
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
    [m_delegate release];
    [super dealloc];
}

-(HVTypeViewItem *)itemKeyAtIndex:(NSUInteger)index
{
    return [m_items objectAtIndex:index];
}

-(NSUInteger)indexOfItemID:(NSString *)itemID
{
    return [m_items indexOfItemID:itemID];
}

-(BOOL)containsItemID:(NSString *)itemID
{
    return ([self indexOfItemID:itemID] != NSNotFound);
}

-(HVItem *)getLocalItemAtIndex:(NSUInteger)index
{
    return [m_store.data getLocalItemWithKey:[self itemKeyAtIndex:index]];
}

-(void)removeLocalItemAtIndex:(NSUInteger)index
{
    return [m_store.data removeLocalItemWithKey:[self itemKeyAtIndex:index]];
}

-(void)removeAllLocalItems
{
    for (NSUInteger i = 0, count = m_items.count; i < count; ++i)
    {
        [self removeLocalItemAtIndex:i];
    }
}

-(HVItem *)getItemAtIndex:(NSUInteger)index
{
    return [self getItemAtIndex:index readAheadCount:20];
}

-(HVItem *)getItemAtIndex:(NSUInteger)index readAheadCount:(NSUInteger)readAheadCount
{
    HVTypeViewItem* key = [m_items objectAtIndex:index];
    HVCHECK_NOTNULL(key);
    
    if (key.isLoadPending)
    {
        return nil; // Will be delivered via delegate
    }
    //
    // Check if we already have this item
    //
    HVItem* item = [m_store.data getLocalItemWithKey:key];
    if (item)
    {
        return item;
    }
    //
    // Find the items we don't already have cached, and start loading them
    //
    NSRange range = [m_items correctRange:NSMakeRange(index, readAheadCount)];
    HVItemCollection* items = [self getItemsInRange:range];
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
    HVItemCollection* items = [self getLocalItemsInRange:range andPendingList:&pendingKeys];
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

-(NSUInteger)putItem:(HVItem *)item
{
    //
    // First, place in the persistent store
    //
    HVCHECK_SUCCESS([m_store.data putItem:item]);
    
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

-(BOOL)updateItemInView:(HVItem *)item
{
    if (![m_items updateDateForHVItem:item])
    {
        return FALSE;
    }

    [self stampUpdated];
    return TRUE;
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
        if ([m_items updateDateForHVItem:[items objectAtIndex:i]])
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

-(BOOL)removeItemFromViewByID:(NSString *)itemID
{
    if (![m_items removeItemByID:itemID])
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
    NSDate* now = [NSDate date];
    return ([now timeIntervalSinceDate:m_lastUpdateDate] > maxAge);
}

-(HVTask *)synchronize
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
        query.maxResults = m_maxItems;
    }
    
    HVGetItemsTask* getItems = [[[HVGetItemsTask alloc] initWithQuery:query andCallback:^(HVTask *task) {
        
        [self synchronizeViewCompleted:task.result];
        
    }] autorelease];  
    
    [query release];
    
    [getItems start];
    
    return getItems;

LError:
    return nil;
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
    return [m_store saveView:self name:name];
}

+(HVTypeView *)loadViewNamed:(NSString *)name fromStore:(HVLocalRecordStore *)store
{
    return [store loadView:name];
}

+(HVTypeView *)getViewForTypeClassName:(NSString *)className
{
    NSString *typeID = [[HVTypeSystem current] getTypeIDForClassName:className]; 
    return [HVTypeView getViewForTypeID:typeID];
}

+(HVTypeView *)getViewForTypeID:(NSString *)typeID
{
    HVRecordReference* record = [HVClient current].currentRecord;
    HVLocalRecordStore* recordStore = [[HVClient current].localVault getRecordStore:record];
    
    HVTypeView *view = [HVTypeView loadViewNamed:typeID fromStore:recordStore];
    if (!view)
    {
        view = [[[HVTypeView alloc] initForTypeID:typeID overStore:recordStore] autorelease];
    }
    
    return view;
}

-(void)updateViewWith:(HVTypeViewItems *)items
{
    HVCLEAR(m_items);
    HVRETAIN(m_items, items);
    [self stampUpdated];
}

-(void)keysNotRetrieved:(NSArray *)keys withError:(id)error
{
    [self setDownloadStatus:FALSE forKeys:keys];
    [self notifySyncFailed:error];
}

-(void)itemsRetrieved:(HVItemCollection *)items forKeys:(NSArray *)keys
{
    if (items && items.count > 0)
    {
        [self itemsAvailableInStore:items];
    }
    //
    // Not all keys may have resulted in items being retrieved
    //   
    if (items.count < keys.count)
    {
        NSMutableDictionary* itemsByID = [items createIndexByID];
        if (itemsByID)
        {
            NSMutableArray* keysNotFound = [[[NSMutableArray alloc] init] autorelease];
            for (HVItemKey* key in keys) 
            {
                if (![itemsByID objectForKey:key.itemID])
                {
                    [keysNotFound addObject:key];
                }
            }
            [itemsByID release];
            [self keysNotAvailableInStore:keysNotFound];
        }
    }
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_typeID, c_element_typeID);
    HVSERIALIZE(m_filter, c_element_filter);
    HVSERIALIZE_DATE(m_lastUpdateDate, c_element_updateDate);
    HVSERIALIZE(m_items, c_element_items);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_typeID, c_element_typeID);
    HVDESERIALIZE(m_filter, c_element_filter, HVItemFilter);
    HVDESERIALIZE_DATE(m_lastUpdateDate, c_element_updateDate);
    HVDESERIALIZE(m_items, c_element_items, HVTypeViewItems);
}

@end

@implementation HVTypeView (HVPrivate)

-(void)setTypeID:(NSString *)typeID
{
    HVRETAIN(m_typeID, typeID);
}

-(void)setFilter:(HVTypeFilter *)filter
{
    HVRETAIN(m_filter, filter);
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

-(void)setItems:(HVTypeViewItems *)items
{
    HVRETAIN(m_items, items);
}

-(void)synchronizeViewCompleted:(HVItemQueryResults *)results
{
    HVTypeViewItems* newViewItems = [[HVTypeViewItems alloc] init];
    HVTypeViewItems* prevItems = [m_items retain];
    @try 
    {
        if (results.hasResults)
        {
            HVItemQueryResult* result = results.firstResult;
            if (![newViewItems addQueryResult:result])
            {
                [HVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_Sync)];
            }
        }
        self.items = newViewItems;
        //
        // Collect set of keys that are no longer in this view
        //
        NSMutableArray *keysRemoved = [prevItems selectItemsNotIn:newViewItems];
        [self stampUpdated];
        [self notifySynchronized:keysRemoved];
    }
    @catch (id ex) 
    {
        [ex log];
        [self notifySyncFailed:ex];
    }
    @finally 
    {
        [newViewItems release];
        [prevItems release];
    }
}

-(HVItemCollection *)getLocalItemsInRange:(NSRange)range andPendingList:(NSMutableArray **)pending
{
    *pending = nil;
    
    NSMutableArray* pendingKeys = nil;
    HVItemCollection* items = [[[HVItemCollection alloc] initWithCapacity:range.length] autorelease];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        HVTypeViewItem* key = [m_items objectAtIndex:i];
        HVItem* item = [m_store.data getLocalItemWithKey:key];
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
    // Only download those items not already being downloaded
    //
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
    //
    // Nothing new to download
    //
    if ([NSArray isNilOrEmpty:keys])
    {
        return nil;
    }
    //
    // Launch the download task
    //
    HVTask* task = [m_store.data downloadItemsWithKeys:keys inView:self];
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

-(void)itemsAvailableInStore:(HVItemCollection *)items
{
    [self setDownloadStatus:FALSE forItems:items];
    [self notifyItemsAvailable:items];
}

-(void)keysNotAvailableInStore:(NSArray *)keys
{
    if ([NSArray isNilOrEmpty:keys])
    {
        return;
    }
    
    [self notifyKeysNotAvailable:keys];
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

-(void)notifyItemsAvailable:(HVItemCollection *)items
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate itemsAvailable:items inView:self];
            }
        }
    },  m_isDelegateInMainThread);
  
}

-(void)notifyKeysNotAvailable:(NSArray *)keys
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate keysNotAvailable:keys inView:self];
            }
        }
    }, m_isDelegateInMainThread);
 }

-(void)notifySynchronized:(NSArray *) keysRemoved
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate synchronizationCompletedInView:self keysRemoved:keysRemoved];
            }
        }
    }, m_isDelegateInMainThread);
}

-(void)notifySyncFailed:(id)error
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate synchronizationFailedInView:self withError:error];
            }
        }
    }, m_isDelegateInMainThread);
}

-(void)notifyItemsAvailableAtIndexes:(HVIndexList *)indexes
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate itemsAvailableAtIndexes:indexes inView:self];
            }
        }
    }, m_isDelegateInMainThread);   
}

-(void) notifyItemsNotAvailableAtIndexes:(HVIndexList *)indexes
{
    safeInvokeActionEx(^{
        @synchronized(self)
        {
            if (m_delegate)
            {
                [m_delegate itemsNotAvailableAtIndexes:indexes inView:self];
            }
        }
    }, m_isDelegateInMainThread);   
 
}

-(void)stampUpdated
{
    self.lastUpdateDate = [NSDate date];
}

@end
