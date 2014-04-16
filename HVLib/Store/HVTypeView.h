//
//  HVTypeView.h
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

#import <Foundation/Foundation.h>
#import "XLib.h"
#import "HVAsyncTask.h"
#import "HVTypeViewItems.h"
#import "HVLocalVault.h"
#import "HVItemFilter.h"
#import "HVBlock.h"

@class HVSynchronizedStore;
@class HVTypeView;

enum HVTypeViewReadAheadMode
{
    HVTypeViewReadAheadModePage,
    HVTypeViewReadAheadModeSequential
};

extern const int c_hvTypeViewDefaultReadAheadChunkSize;

//
// See notes on HVTypeView interface before you read this
//
@protocol HVTypeViewDelegate <NSObject>
//
// Called when asynchronously retrieved items become available locally
// viewChanged indicates that the SORT order of the typeView was impacted when new items were pulled.
// If so, you should RELOAD any associated views, such as UITableView
// Otherwise you can do a more target reload of changed rows only
//
-(void) itemsAvailable:(HVItemCollection *)items inView:(HVTypeView *)view viewChanged:(BOOL) viewChanged;
//
// Keys for items no longer available in HealthVault. They have been REMOVED from the view. 
// You should now refresh your UI etc. 
//
-(void) keysNotAvailable:(NSArray *) keys inView:(HVTypeView *) view;
//
// The full view sync is complete
//
-(void) synchronizationCompletedInView:(HVTypeView *) view;
//
// Called whenever there was an error pulling data from HealthVault asynchronously
//
-(void) synchronizationFailedInView:(HVTypeView *) view withError:(id) ex;

@end

@protocol HVTypeView <NSObject>

@property (readonly, nonatomic) NSString* typeID;
@property (readonly, nonatomic) HVRecordReference* record;
@property (readwrite, nonatomic, retain) NSDate* lastUpdateDate;
@property (readonly, nonatomic) NSUInteger count;
@property (readwrite, nonatomic) NSInteger maxItems;

-(HVTypeViewItem *) itemKeyAtIndex:(NSUInteger) index;
-(NSUInteger)indexOfItemID:(NSString *)itemID;

-(HVItem *) getItemAtIndex:(NSUInteger) index;
-(HVItem *) getItemByID:(NSString *) itemID;

-(HVItemCollection *) getItemsInRange:(NSRange) range;

-(HVItem *) getLocalItemAtIndex:(NSUInteger) index;
-(HVItem *) getLocalItemWithKey:(HVItemKey *) key;
-(NSArray *) keysOfItemsNeedingDownloadInRange:(NSRange) range;

-(HVTask *) ensureItemsDownloadedInRange:(NSRange)range withCallback:(HVTaskCompletion)callback;

-(BOOL) isStale:(NSTimeInterval) maxAge;
//
// If there are pending changes, refresh will return nil... 
//
-(HVTask *) refresh;
-(HVTask *) refreshWithCallback:(HVTaskCompletion) callback;
//
// Returns the query used to refresh this view
//
-(HVItemQuery *) createRefreshQuery;
-(BOOL) replaceKeys:(HVTypeViewItems *) items;

@end

//----------------------------------------------
//
// HVTypeView makes it easy to write asynchronous UITableView displays of HealthVault data.
// It leverages offline local data storage/replication/background synchronization.
//
// Items are automatically fetched down the LocalRecordStore as needed.
// All data download is transparent, as needed, in the background.
// New items are re-fetched when needed.
//
// HVTypeView adopts the HVTypeView protocol.
//
// HVTypeViews are persistable - i.e. they can be saved and loaded from disk. 
//
// You always use HVTypeView from the main thread.
//
// HVTypeView uses HVTypeViewDelegate to notify you of changes.
// The object guarantees that all background CHANGES are also made in THE MAIN (UI) THREAD.
// All notifications are also delivered in the Main UI thread.

// This considerably simplifies the burden of displaying data. All changes are always
// serialized through the main thread--whether the changes are made by the user (UI) OR whether
// the changes are made due to background work. Your UI doesn't have to worry about the type view
// being changed under you while you are handling an Action...
//
// Sticking to the Main UI thread also allows you to null out the delegate safely
// When you do so, you will no longer receive (or protect against) any pending background notifications
// that could confuse your code.
//
//----------------------------------------------
@interface HVTypeView : XSerializableType<HVTypeView>
{
    NSString* m_typeID;
    HVTypeFilter* m_filter;
    NSDate* m_lastUpdateDate;
    NSInteger m_maxItems;
  
    HVTypeViewItems* m_items;
    HVLocalRecordStore* m_store;
    
    id<HVTypeViewDelegate> m_delegate;
    enum HVTypeViewReadAheadMode m_readAheadMode;
    NSInteger m_readAheadChunkSize;
    BOOL m_enforceTypeCheck;
    
    NSInteger m_tag;
}

@property (readonly, nonatomic) HVRecordReference* record;
@property (readonly, nonatomic) HVSynchronizedStore* data;
@property (readwrite, nonatomic, retain) HVLocalRecordStore* store;
@property (readwrite, nonatomic, assign) id<HVTypeViewDelegate> delegate;
//
// These properties are persisted when you store a type view to disk
//
@property (readonly, nonatomic) NSString* typeID;
@property (readonly, nonatomic) HVTypeFilter* filter;
@property (readwrite, nonatomic, retain) NSDate* lastUpdateDate;
@property (readonly, nonatomic) NSUInteger count;
@property (readwrite, nonatomic) NSInteger maxItems;
@property (readwrite, nonatomic) NSInteger readAheadChunkSize;
//
// These properties are NOT persisted when you save to disk
// Set them to your desired settings when you load saved views
//
@property (readwrite, nonatomic) NSInteger tag;
@property (readwrite, nonatomic) enum HVTypeViewReadAheadMode readAheadMode;
// Deprecated. Use readAheadMode instead
@property (readwrite, nonatomic) BOOL readAheadModeChunky __deprecated;
@property (readwrite, nonatomic) BOOL enforceTypeCheck;
//
// These are determined dynamically
//
@property (readonly, nonatomic) NSDate* minDate;
@property (readonly, nonatomic) NSDate* maxDate;

//------------------
//
// Initializers
//
//-------------------
-(id) initForTypeID:(NSString *) typeID overStore:(HVLocalRecordStore *) store;
-(id) initForTypeID:(NSString *)typeID filter:(HVTypeFilter *) filter overStore:(HVLocalRecordStore *) store;
-(id) initForTypeID:(NSString *)typeID filter:(HVTypeFilter *) filter items:(HVTypeViewItems *) items overStore:(HVLocalRecordStore *) store;
-(id) initFromTypeView:(HVTypeView *) typeView andItems:(HVTypeViewItems *) items;

//------------------------------------
//
// Methods
// Also look at the HVTypeView protocol
//
//------------------------------------

-(HVTypeViewItem *) itemKeyAtIndex:(NSUInteger) index;
-(NSUInteger) indexOfItemID:(NSString *) itemID;
//
// Returns the FIRST item that has the closest (or equal) date to the one supplied
// 
-(NSUInteger) indexOfItemWithClosestDate:(NSDate *) date;
-(NSUInteger) indexOfItemWithClosestDate:(NSDate *)date firstEqual:(BOOL) firstEqual;

-(BOOL) containsItemID:(NSString *) itemID;
-(HVTypeViewItem *) itemForItemID:(NSString *) itemID;
//
// Very useful for finding the closest item by DAY
//
-(NSUInteger) indexOfFirstDay:(NSDate *)date;
-(NSUInteger) indexOfFirstDay:(NSDate *)date startAt:(NSUInteger) baseIndex;

//
// maxAgeInSeconds
//
-(BOOL) isStale:(NSTimeInterval) maxAge;
//
// Synchronize view but not data.
// Calls delegate when complete
//
-(HVTask *) synchronize;
//
// Synchronize HVItems associated with this view
// Calls delegate when complete
//
-(HVTask *) synchronizeData;

//---------------------------
//
// Synchronized get/put Methods
// These methods return locally cached items immediately.
// If no local item is immediately available, they return nil.
//
// PENDING items are fetched in the background.
// When they become available, self.delegate is notified
//
//------------------------------
-(HVItem *) getItemAtIndex:(NSUInteger) index;
-(HVItem *) getItemAtIndex:(NSUInteger) index readAheadCount:(NSUInteger) readAheadCount;
-(HVItem *) getItemByID:(NSString *) itemID;
//
// Returns what items it has, and triggers an async pull of the remaining
//  HVItemCollection.count == range.length
//  Any positions that do not have a local item get an NSNull object
//
-(HVItemCollection *) getItemsInRange:(NSRange) range;
-(HVItemCollection *) getItemsInRange:(NSRange) range downloadTask:(HVTask **) task;
//
// If includeNull is true:
//  HVItemCollection.count == range.length
//  Any positions that do not have a local item get an NSNull object
//
-(HVItemCollection *) getItemsInRange:(NSRange) range nullIfNotFound:(BOOL) includeNull;
-(HVItemCollection *) getItemsInRange:(NSRange) range nullIfNotFound:(BOOL) includeNull downloadTask:(HVTask **) task;
//
// Return a list of keys for whom we do not already have data available locally
//
-(NSArray *) keysOfItemsNeedingDownloadInRange:(NSRange) range;
//
// Returns a nil task if all items are already available
// Otherwise returns a task object and tries to fetch unavailable items from HealthVault
// Completeions will be delivered in the main thread
//
-(HVTask *)ensureItemsDownloadedInRange:(NSRange)range withCallback:(HVTaskCompletion)callback;

//------------------
//
// Operations that alter the view AND any items in the local store
//
//------------------
//
// Removes item from the view AND any associated LOCAL data only.
// Does NOT delete the item from HealthVault
//
-(BOOL) removeItemAtIndex:(NSUInteger) index;
//
// Stores items in the LOCAL STORE ONLY AND updates the view
// Does NOT automatically push the data to HealthVault.
// Use the HVSynchronizedType object if you want data to be pushed into HealthVault
// HVSynchronizedType will background commit the data to HealthVault
//
-(NSUInteger) putItem:(HVItem *) item;
-(BOOL) putItems:(HVItemCollection *) items;

//------------------
//
// Operations that go directly against the local store
// They do NOT alter the view
//
//------------------

-(HVItem *) getLocalItemAtIndex:(NSUInteger) index;
-(HVItem *) getLocalItemWithKey:(HVItemKey *) key;

-(void) removeLocalItemAtIndex:(NSUInteger) index;
-(void) removeAllLocalItems;

//------------------
//
// Operations that alter the view ONLY
// They do not touch the local store
//
//------------------
//
// Updates the item's position in the view. The position is impacted by the view's sort order
// Returns the new position of item in the view.
// Also returns the old position of the item, if it already existed, or NSNotFound
//
-(NSUInteger) updateItemInView:(HVItem *) item prevIndex:(NSUInteger *) prevIndex;
-(NSUInteger) updateItemInView:(HVItem *) item;

-(BOOL) removeItemFromViewByID:(NSString *) itemID;
-(BOOL) removeItemsFromViewByID:(NSArray *) itemIDs;

//----------------------------------
//
// Persistance and factory methods
//
//----------------------------------
//
// Saves the view to disk.
// The view name is autogenerated using self.typeID
//
-(BOOL) save;
-(BOOL) saveWithName:(NSString*) name;
//
// If a saved view is found on disk, load it...
//
+(HVTypeView *) loadViewNamed:(NSString *) name fromStore:(HVLocalRecordStore *) store;
//
// Loads views - using a name autogenerated using typeID
// 
+(HVTypeView *) getViewForTypeClassName:(NSString *) className inRecord:(HVRecordReference *) record;
+(HVTypeView *) getViewForTypeID:(NSString *)typeID inRecord:(HVRecordReference *) record;
+(HVTypeView *) getViewForTypeID:(NSString *)typeID andRecordStore:(HVLocalRecordStore *)store;

//
// Delegate callbacks invoked by HVSynchronizedStore
//
-(void) keysNotRetrieved:(NSArray *) keys withError:(id) error;
-(void) itemsRetrieved:(HVItemCollection *) items forKeys:(NSArray *) keys; // Not all keys may result in a match

//----------------------------------
//
// Subviews
//
//----------------------------------
-(HVTypeView *) subviewForRange:(NSRange) range;

@end

