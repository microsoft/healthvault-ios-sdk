//
//  MHVSynchronizedType.h
//  MHVLib
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
//
//

#import <Foundation/Foundation.h>
#import "MHVTypeView.h"

//-------------------------------------------------------------------------------------------
//
// HVSynchronizedTypes provides simple 2-way read-write synchronization and offline work model for
// HealthVault types.
//
// Each HealthVault Item Type (Weight, Blood Pressure, Medication etc.) has an equivalent
// SynchronizedType.
//
// Each SynchronizedType is a MHVTypeView (see MHVTypeView.h).
// Please read notes in MHVTypeView.h and MHVSyncView.h first.
//
// SynchronizedTypes store HVItems on the local device--in the application's LocalVault.
// Items are downloaded and updated as necessary.
//
// You can add, edit or remove item data to/from a SynchronizedType entirely OFFLINE.
// SynchronizedTypes track changes to items.
// They background commit/synchronize those changes with the HealthVault cloud store.
//
// Tracking of changes and commits is PERSISTENT--i.e. it survives application restarts,
// network connectivity issues and the like.
// A change queue that is interrupted because the application is closed or network lost will
// resume where it left off the next time the application triggers a commit of pending changes.
//
// To support 2-way synchronization the application must:
//  - Periodically trigger a commit of pending changes back to HealthVault.
//  - Optionally periodically refresh the type
//
// The two are independant operations. The application decides the frequency at which they
// should occur.
// Doing both is straightforward and the **SynchronizedType SAMPLE** demonstrates the methods
// and helper classes that do the needful.
//
// *COMMITTING CHANGES*
// The application periodically triggers a commit of pending changes to HealthVault.
// The application decides the frequency at which changes are background committed.

// The typical application commits changes by using the *MHVItemCommitScheduler* class.
// Advanced applications may use lower level methods to customize the behavior.
//
// The application can:
//     - Commit ALL pending changes for all SynchronizedTypes in all records
//     in the LocalVault (MHVLocalVault commitOfflineChangesWithCallback) at one go
//     - Commit changes for a specific record (HVLocalRecodeStore commitOfflineChangesWithCallback)
//
// *REFRESHING*
// Refreshing a SynchronizedType is identical to refreshing a MHVTypeView.
// Refresh allows the SynchronizedType to discover new items, updates and removes made by
// OTHER applications to the user's HealthVault record. Refresh is the *read" part of 2-way
// synchronization.
//  - The application determines if a SynchronizedType is stale--last updated more than some time
//    interval earlier. It then calls refresh.
//  - The application calls refresh in response to user or other action
//  - The application can refresh mutliple SynchronizedTypes with minimal
//    roundtrips by using the MHVMultipleTypeViewRefresher class
// A SynchronizedType will not refresh if there are pending changes that must be comitted to
// HealthVault first.
//
// An application that never refreshes a SynchronizedType will continue to function correctly.
// However, it will never discover changes made by other applications. It will however
// operate correctly with items it added/updated/removed.
//
//-----------------------------------------------------------------------

@class MHVSynchronizedType;
@class MHVSynchronizationManager;

//-----------------------------------------------------------------
//
// *NOTIFICATIONS*
//
// MHVSynchronizedType fires notifications in 2 ways:
//
//  - Singlecast to MHVSynchronizedTypeDelegate delegate
//  - Broadcast to [NSNotificationCenter defaultCenter]
//
//-----------------------------------------------------------------
//
// BROADCAST EVENT NAMES
//
HVDECLARE_NOTIFICATION(HVSynchronizedTypeItemsAvailableNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeKeysNotAvailableNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeSyncCompletedNotification);
HVDECLARE_NOTIFICATION(HVSynchronizedTypeSyncFailedNotification);
//
// Single cast notifications
//
@protocol MHVSynchronizedTypeDelegate <NSObject>
//
// Called when asynchronously retrieved items become available locally
// If typeChanged is true, you may want to refresh your entire UI
// Otherwise you can only redraw the items that are now available
//
-(void) synchronizedType:(MHVSynchronizedType *) type itemsAvailable:(MHVItemCollection *) items typeChanged:(BOOL) changed;
//
// Keys for items no longer available in HealthVault. They have been REMOVED from the type.
// You should now refresh your UI etc.
//
-(void) synchronizedType:(MHVSynchronizedType *) type keysNotAvailable:(NSArray *)keys;

-(void) synchronizedTypeSyncCompleted:(MHVSynchronizedType *) type;
-(void) synchronizedType:(MHVSynchronizedType *) type syncFailedWithError:(id) ex;

@end

//-----------------------------------------------------------------
//
// Object that makes it simple to:
//  - Safely edit a locally stored item
//  - Track changes in the commit queue
//
//-----------------------------------------------------------------
@interface MHVItemEditOperation : NSObject
{
@private
    MHVItem* m_item;
    MHVSynchronizedType* m_type;
    MHVAutoLock* m_lock;
}

//
// A deep clone of the original item, so you can safely edit/alter its
// properties in memory without any impact elsewhere
//
@property (readonly, nonatomic) MHVItem* item;

//
// Call commit if you want the changes to be:
//   - written to the LocalVault
//   - added to the change queue for later background commit
//
// You MUST call commit if you want to save your changes.
//By default, all edit operations are treated as Cancel
//
-(BOOL) commit;
//
// Default.. abandon this edit operation
//
-(void) cancel;

@end

//----------------------------------------------
//
// See documentation at the top of this file
// See MHVTypeView for additional docs.
//
//----------------------------------------------
@interface MHVSynchronizedType : NSObject<MHVTypeView, MHVTypeViewDelegate, NSDiscardableContent>
{
@private
    NSString* m_typeID;
    NSString* m_viewName;
    MHVSynchronizationManager* m_syncMgr;
    MHVTypeView* m_view;
    NSInteger m_readAheadChunkSize;
    BOOL m_broadcastNotifications;

    int m_accessCount;
}

@property (readwrite, nonatomic, strong) MHVSynchronizationManager* syncMgr;
@property (readwrite, nonatomic, weak) id<MHVSynchronizedTypeDelegate> delegate;  // weak ref
@property (readwrite, nonatomic) NSInteger readAheadChunkSize;
@property (readonly, nonatomic) BOOL isLoaded;
@property (readwrite, nonatomic) BOOL broadcastNotifications;

-(id) initForTypeID:(NSString *) typeID withMgr:(MHVSynchronizationManager *) syncMgr;

//
// Are there any pending changes for this type that have not been committed to HealthVault?
//
-(BOOL) hasPendingChanges;
//
// Returns nil if the item is already available locally
//
-(MHVTask *) ensureItemDownloadedForKey:(MHVItemKey *) key withCallback:(HVTaskCompletion) callback;

//---------------------------------------------
//
// MHVSynchronizedType adopts the MHVTypeView protocol
// See MHVTypeView documentation for list of all methods
// Additional methods below
//
//---------------------------------------------

-(BOOL) addNewItem:(MHVItem *) item;
//
// Will return nil if the item is not available locally OR the item could not be locked
//
-(MHVItemEditOperation *) openItemForEditWithKey:(MHVItemKey *) key;
-(MHVItemEditOperation *) openItemForEditAtIndex:(NSUInteger) index;
-(BOOL) putItem:(MHVItem *) item editLock:(MHVAutoLock *) lock;

-(BOOL) removeItemWithKey:(MHVItemKey *) key;
-(BOOL) removeItemAtIndex:(NSUInteger) index;
//
// Will return null if there are pending changes not yet committed
//
-(MHVTask *) refresh;
//
// Save this type to disk
//
-(BOOL) save;
-(BOOL) removeAllLocalItems;

//---------------------------------------------
//
// Internal methods used by the SDK
//
//---------------------------------------------
-(BOOL) applyChangeCommitSuccess:(MHVItemChange *) change itemLock:(MHVAutoLock *) lock;
+(NSString *) makeViewNameForTypeID:(NSString *) typeID;

-(BOOL) isContentDiscardable;

@end

