//
//  HVTypeView.h
//  HVLib
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

#import <Foundation/Foundation.h>
#import "HVSyncView.h"

//---------------------------------------------------------------------------------
//
// *REQUIRED*
// Pleaes read notes on HVSyncView (HVSyncView.h) first
//
// HVTypeView is a SPECIALIZED SyncView
//
//  - It is scoped to exactly ONE HealthVault Item Type
//  - It *does not* let you customize the query associated with the view
//  - It *does* let you customize the ItemFilter for the view
//
//---------------------------------------------------------------------------------

@class HVSynchronizedStore;
@class HVTypeView;

enum HVTypeViewReadAheadMode
{
    HVTypeViewReadAheadModePage,
    HVTypeViewReadAheadModeSequential
};

extern const int c_hvTypeViewDefaultReadAheadChunkSize;

//---------------------------------------------------------------------------
//
// Protocol adopted by type views...
//
// *REQUIRED*
// Please read about HVSyncView first. (HVSyncView.h)
//
// TypeViews are COLLECTIONS of HVTypeViewItems. HVTypeViewItem inherits from HVItemKey
// See HVTypeViewItems.h
//
// HVTypeViews are SORTED by EffectiveDate - the same sort order in which
// the HealthVault platform returns items, and the order in in which the HealthVault
// Shell displays items. The sort order is:
//  - EffectiveDate [descending]
//  - itemID [ascending]
//
//---------------------------------------------------------------------------
@protocol HVTypeView <HVSyncView>
//
// The typeID of the HealthVault Type for which this is a view
//
@property (readonly, nonatomic) NSString* typeID;
//
// The maximum number of items for this view. Useful for large views
// This lets you work with the most RECENT maxItems
//
@property (readwrite, nonatomic) NSInteger maxItems;

//----------------------------------------------------------
//
// Lookup methods
// More methods in HVSyncView
//
//----------------------------------------------------------
-(HVTypeViewItem *) itemKeyAtIndex:(NSUInteger) index;
//
// Reverse lookup.. find the location of the given itemID in the collection
//
-(NSUInteger) indexOfItemID:(NSString *)itemID;
//
// Returns null if not found
//
-(HVItem *) getItemByID:(NSString *) itemID;
-(HVItem *) getLocalItemWithKey:(HVItemKey *) key;
//
// Used if you want to fetch/sync/refresh items using your own logic
//
-(NSArray *) keysOfItemsNeedingDownloadInRange:(NSRange) range;
-(HVTask *) ensureItemsDownloadedInRange:(NSRange)range withCallback:(HVTaskCompletion)callback;
-(BOOL) replaceKeys:(HVTypeViewItems *) items;

@end

//-----------------------------------------------------------
//
// Delegate for HVTypeView objects
// HVTypeView automatically downloads items from HealthVault as needed... in the background
// You are notified when these downloads complete
//
//-----------------------------------------------------------
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

//---------------------------------------------------------
//
// *REQUIRED*
// Please read notes on HVTypeView and HVSyncView protocols.
//
// HVTypeView adopts the HVTypeView protocol.
// HVTypeView also makes it easy to write asynchronous UITableView displays of HealthVault data.
// You always use HVTypeView from the main thread.
//
// HVTypeViews are persistable AND xml serializable - i.e. they can be saved and loaded from disk.
//
// HVTypeView uses HVTypeViewDelegate to notify you of changes and updates to
// the iview.
//
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
    
    enum HVTypeViewReadAheadMode m_readAheadMode;
    NSInteger m_readAheadChunkSize;
    BOOL m_enforceTypeCheck;
    
    NSInteger m_tag;
}

@property (readonly, nonatomic, strong) HVRecordReference* record;
@property (readonly, nonatomic, strong) HVSynchronizedStore* data;
@property (readwrite, nonatomic, strong) HVLocalRecordStore* store;
@property (readwrite, nonatomic, weak) id<HVTypeViewDelegate> delegate;
//
// These properties are persisted when you store a type view to disk
//
@property (readonly, nonatomic, strong) NSString* typeID;
@property (readonly, nonatomic, strong) HVTypeFilter* filter;
@property (readwrite, nonatomic, strong) NSDate* lastUpdateDate;
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
@property (readonly, nonatomic, strong) NSDate* minDate;
@property (readonly, nonatomic, strong) NSDate* maxDate;

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
// Also look at the HVTypeView protocol above
//
//------------------------------------
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
// Same as synchronize
// You are notified of refresh status via calls to delegates
//
-(HVTask *) refresh;
//
// Synchronize view but not data.
// Calls delegate when complete
// DEPRECATED METHOD. Use refresh instead
//
-(HVTask *) synchronize;
//
// Synchronize HVItems associated with this view
// Calls delegate when complete
//
-(HVTask *) synchronizeData;

//---------------------------
//
// See HVSyncView and HVTypeView protocols for a list
// of base methods to fetch items with
//
// PENDING items are fetched in the background.
// When they become available, self.delegate is notified
//
//------------------------------
-(HVItem *) getItemAtIndex:(NSUInteger) index readAheadCount:(NSUInteger) readAheadCount;
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

