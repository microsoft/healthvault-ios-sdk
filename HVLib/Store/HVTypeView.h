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

@class HVSynchronizedStore;
@class HVTypeView;

//
// See notes on HVTypeView before you read this
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

//----------------------------------------------
//
// HVTypeView makes it easy to write asynchronous UITableView displays of HealthVault data.
// It leverages offline local data storage/replication/background sync. All data download happens
// transparently, as needed, in the background.
//
// HVTypeViews are persistable - i.e. they can be saved and loaded from disk. 
//
// HVTypeView uses HVTypeViewDelegate to notify you of changes.
//
// Guarantees that all CHANGES are made in THE MAIN UI THREAD.
//
// Sticking to the UI thread also allows you to null out the delegate safely.
// When you do so, you will no longer receive (or protect against) any pending background notifications
// that could confuse your code.
//
//----------------------------------------------
@interface HVTypeView : XSerializableType
{
    NSString* m_typeID;
    HVTypeFilter* m_filter;
    NSDate* m_lastUpdateDate;
    NSInteger m_maxItems;
  
    HVTypeViewItems* m_items;
    HVLocalRecordStore* m_store;
    
    id<HVTypeViewDelegate> m_delegate;
    BOOL m_readAheadModeChunky;
    
    NSInteger m_tag;
}

@property (readonly, nonatomic, retain) HVRecordReference* record;
@property (readonly, nonatomic) NSString* typeID;
@property (readonly, nonatomic) HVTypeFilter* filter;
@property (readwrite, nonatomic, retain) NSDate* lastUpdateDate;
@property (readwrite, nonatomic) NSInteger maxItems;

@property (readonly, nonatomic) NSUInteger count;
@property (readwrite, nonatomic, retain) HVLocalRecordStore* store;
@property (readwrite, nonatomic, retain) id<HVTypeViewDelegate> delegate;

@property (readwrite, nonatomic) NSInteger tag;
@property (readwrite, nonatomic, assign) BOOL readAheadModeChunky;

@property (readonly, nonatomic) NSDate* minDate;
@property (readonly, nonatomic) NSDate* maxDate;

//------------------
//
// Initializers
//
//-------------------
-(id) initForTypeID:(NSString *) typeID overStore:(HVLocalRecordStore *) store;
-(id) initForTypeID:(NSString *)typeID filter:(HVTypeFilter *) filter overStore:(HVLocalRecordStore *) store;

//------------------
//
// Methods
//
//-------------------

-(HVTypeViewItem *) itemKeyAtIndex:(NSUInteger) index;
-(NSUInteger) indexOfItemID:(NSString *) itemID;
-(NSUInteger) indexOfItemWithClosestDate:(NSDate *) date;
-(BOOL) containsItemID:(NSString *) itemID;
-(HVTypeViewItem *) itemForItemID:(NSString *) itemID;

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
-(HVTask *) synchronizeDataInRange:(NSRange) range;

//---------------------------
//
// Synchronized get/put Methods
// These methods return locally cached items immediately. If no local item available, return nil
// PENDING items are fetched in the background.
// When they become available, self.delegate is notified
//
//------------------------------
-(HVItem *) getItemAtIndex:(NSUInteger) index;
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
// Removes item from the view AND any associated data stored LOCALLY only.
// Does not however delete the item from HealthVault
//
-(BOOL) removeItemAtIndex:(NSUInteger) index;
//
// Stores items in the local store AND updates the view
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
-(void) removeLocalItemAtIndex:(NSUInteger) index;
-(void) removeAllLocalItems;

//------------------
//
// Operations that alter the view ONLY
// They do not touch the local store
//
//------------------
//
// Updates the view and stores the item locally
// Returns the new position of item in the view.
// Also returns the old position of the item, if it already existed, or NSNotFound
//
-(NSUInteger) updateItemInView:(HVItem *) item prevIndex:(NSUInteger *) prevIndex;

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


//
// Delegate callbacks invoked by HVSynchronizedStore
//
-(void) keysNotRetrieved:(NSArray *) keys withError:(id) error;
-(void) itemsRetrieved:(HVItemCollection *) items forKeys:(NSArray *) keys; // Not all keys may result in a match

@end

