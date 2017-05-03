//
//  HVSyncView.h
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
//

#import <Foundation/Foundation.h>
#import "XLib.h"
#import "HVAsyncTask.h"
#import "HVTypeViewItems.h"
#import "HVLocalVault.h"
#import "HVItemFilter.h"
#import "HVBlock.h"

//---------------------------------------------------------------------------------
//
// SyncViews implement a simple model for maintaing read-only OFFLINE/Local Storage
// views and caches of the items in a HealthVault record.
//
// SyncViews automatically download and store copies of HealthVault items (HVItems) in
// your LocalVault as needed.
// Like Database views, each SyncView has an associated Query (HVItemQuery)
//
// SyncView implement read-only synchronization, downloading changed items when required.
// SyncView use a simple synchronization and caching model--similar to that used by
// HTML & RSS.
//
// The Query for a view defines the set of HVItems in the view.
// Each SyncView maintains a COLLECTION (array) of the KEYS (HVItemKey) for the items in
// the view.
//     - The view fetches ONLY the updated set of ItemKeys when it is REFRESHED (synchronized).
//     - The view does not fetch the *actual* item data until necessary.
//     - Keys are relatively small in size
//     - The collection of item keys representing the view can optionally be saved and
//      loaded from the LocalVault.
//
//     - When the caller asks for the HVItem for a particular ItemKey, the view checks
//      the LocalVault for a copy that was downloaded earlier - EITHER by this view or another.
//          - BOTH the itemID and the version stamp must match.
//          - If a local copy is available (the itemID & the version matched), it returns
//          the item immediately.
//          (All Views share the same underlying LocalVault. An item that appears in multiple
//          views and was downloaded via one...is automatically available for the others).
//          - If a local item is not available, the view downloads the item from HealthVault
//          in the background and lets you know when the item is available.
//          - The view may chose to *read ahead* and download additional items in anticipation
//          of future usage.
//
//     - Like an HTML page or RSS feed, the application chooses to periodically REFRESH the SyncView
//          - The application decides that a SyncView is *stale*- i.e. not refreshed for some
//          time interval, such as 1 day.
//          OR the user hits a refresh button.
//          - This refreshed set of keys can be saved to the LocalVault and subsequently loaded
//          from the local store, just like a cached HTML page or RSS feed.
//          - For any given View, virtually ALL the ItemKeys will be unchanged from refresh to refresh.
//          - If a matching HVItem was downloaded by any of your views,
//          - Thus, once downloaded, an HVItem will only ever need to downloaded again if:
//              - The item was updated (version stamp is different)
//              - The item was deleted from the local store
//          - This minimizes the amount of data that must be periodically synchronized.
//
// Classes that adopt the HVSyncView protocol use different mechanisms to notify
// the application of changes to the view.
//
//---------------------------------------------------------------------------------

@protocol HVSyncView <NSObject>
//
// The record over which this is a view
//
@property (readonly, nonatomic) HVRecordReference* record;
//
// The last time this view was refreshed
//
@property (readwrite, nonatomic, retain) NSDate* lastUpdateDate;
//
// The number of items in this view
//
@property (readonly, nonatomic) NSUInteger count;
//
// The Query Associated with this view
//
-(HVItemQuery *) getQuery;

-(HVItemKey *) keyAtIndex:(NSUInteger) index;

//----------------------------------------------------------
//
// Methods to retrieve items
//
//----------------------------------------------------------
//
// These return null if no local item is available
// A background load is automatically triggered. You are notified of
// progress and results via a delegate or notification model defined by the
// adopter of this protocol
//
-(HVItem *) getItemAtIndex:(NSUInteger) index;
-(HVItemCollection *) getItemsInRange:(NSRange) range;
//
// Work with local copies of data only
// Return null if no local item available
//
-(HVItem *) getLocalItemAtIndex:(NSUInteger) index;
//
// A view is stale if it is older than the given age - it was last updated more than the given
// time interval ago
//
-(BOOL) isStale:(NSTimeInterval) maxAge;
//
// Refresh the view. If the refresh does not start (e.g. READ-WRITE views may have pending changes)
// then this may return NULL
//
-(HVTask *) refreshWithCallback:(HVTaskCompletion) callback;

@end

