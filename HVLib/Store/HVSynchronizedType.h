//
//  HVSynchronizedType.h
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//

#import <Foundation/Foundation.h>
#import "HVTypeView.h"
#import "HVMulticastDelegate.h"

@class HVSynchronizedType;
@class HVSynchronizationManager;

//
// HVSynchronizedType fires notifications in 2 ways:

//  - Singlecast to HVSynchronizedTypeDelegate delegate
//  - Broadcast to [NSNotificationCenter defaultCenter]
//
// Broadcast event names:
//
HVDECLARE_NOTIFICATION(HVSynchronizedTypeItemsAvailableNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeKeysNotAvailableNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeSyncCompletedNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeSyncFailedNotification);
//
// Single cast notifications
//
@protocol HVSynchronizedTypeDelegate <NSObject>
//
// Called when asynchronously retrieved items become available locally
// If typeChanged is true, you may want to refresh your entire UI
// Otherwise you can only redraw the items that are now available
//
-(void) synchronizedType:(HVSynchronizedType *) type itemsAvailable:(HVItemCollection *) items typeChanged:(BOOL) changed;
//
// Keys for items no longer available in HealthVault. They have been REMOVED from the type.
// You should now refresh your UI etc.
//
-(void) synchronizedType:(HVSynchronizedType *) type keysNotAvailable:(NSArray *)keys;

-(void) synchronizedTypeSyncCompleted:(HVSynchronizedType *) type;
-(void) synchronizedType:(HVSynchronizedType *) type syncFailedWithError:(id) ex;

@end

@interface HVItemEditOperation : NSObject
{
@private
    HVItem* m_item;
    HVSynchronizedType* m_type;
    HVAutoLock* m_lock;
}

//
// A deep clone of the original item, so you can safely edit/alter its properties in memory without any impact elsewhere
//
@property (readonly, nonatomic) HVItem* item;

-(BOOL) commit;
-(void) cancel;

@end

//----------------------------------------------
//
// See documentation on HVTypeView
// Same threading rules apply here
//
//----------------------------------------------
@interface HVSynchronizedType : NSObject<HVTypeView, HVTypeViewDelegate, NSDiscardableContent>
{
@private
    NSString* m_typeID;
    NSString* m_viewName;
    HVSynchronizationManager* m_syncMgr;
    HVTypeView* m_view;
    id<HVSynchronizedTypeDelegate> m_delegate;
    NSInteger m_readAheadChunkSize;
    BOOL m_broadcastNotifications;

    int m_accessCount;
}

@property (readwrite, nonatomic, retain) HVSynchronizationManager* syncMgr;
@property (readwrite, nonatomic, assign) id<HVSynchronizedTypeDelegate> delegate;  // weak ref
@property (readwrite, nonatomic) int readAheadChunkSize;
@property (readonly, nonatomic) BOOL isLoaded;
@property (readwrite, nonatomic) BOOL broadcastNotifications;

-(id) initForTypeID:(NSString *) typeID withMgr:(HVSynchronizationManager *) syncMgr;

//
// Are there any pending changes for this type that have not been committed to HealthVault?
//
-(BOOL) hasPendingChanges;
//
// Returns nil if the item is already available locally
//
-(HVTask *) ensureItemDownloadedForKey:(HVItemKey *) key withCallback:(HVTaskCompletion) callback;

//---------------------------------------------
//
// HVSynchronizedType adopts the HVTypeView protocol
// See HVTypeView documentation for list of all methods
// Additional methods below
//
//---------------------------------------------

-(BOOL) addNewItem:(HVItem *) item;
//
// Will return nil if the item is not available locally OR the item could not be locked
//
-(HVItemEditOperation *) openItemForEditWithKey:(HVItemKey *) key;
-(HVItemEditOperation *) openItemForEditAtIndex:(NSUInteger) index;
-(BOOL) putItem:(HVItem *) item editLock:(HVAutoLock *) lock;

-(BOOL) removeItemWithKey:(HVItemKey *) key;
-(BOOL) removeItemAtIndex:(NSUInteger) index;
//
// Save this type to disk
//
-(BOOL) save;
-(BOOL) removeAllLocalItems;

-(BOOL) applyChangeCommitSuccess:(HVItemChange *) change itemLock:(HVAutoLock *) lock;

+(NSString *) makeViewNameForTypeID:(NSString *) typeID;

-(BOOL) isContentDiscardable;

@end

