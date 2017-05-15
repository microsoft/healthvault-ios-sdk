//
//  MHVLocalRecordStore.h
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

#import <Foundation/Foundation.h>
#import "MHVObjectStore.h"
#import "MHVSynchronizationManager.h"

@class MHVStoredQuery;

@interface MHVLocalRecordStore : NSObject
{
@private
    MHVRecordReference* m_record;
    id<MHVObjectStore> m_root;
    id<MHVObjectStore> m_metadata;
    MHVSynchronizationManager* m_dataMgr;
    BOOL m_cache;
}

//-------------------------
//
// Data
//
//-------------------------
//
// Record for which this is a store
//
@property (strong, readonly, nonatomic) MHVRecordReference* record;
//
// Root store for this record
//
@property (readonly, nonatomic) id<MHVObjectStore> root;
//
// Metadata, such as view definitions, etc..
// Child of root
//
@property (strong, readonly, nonatomic) id<MHVObjectStore> metadata;
//
// All Thing Data (Xml) is stored here
//
@property (strong, readonly, nonatomic) MHVSynchronizedStore* data;
//
// Synchronization manager
//
@property (strong, readonly, nonatomic) MHVSynchronizationManager* dataMgr;

//-------------------------
//
// Initializers
//
//-------------------------
//
// NO caching by default.
//
-(id) initForRecord:(MHVRecordReference *) record overRoot:(id<MHVObjectStore>) root;
-(id) initForRecord:(MHVRecordReference *) record overRoot:(id<MHVObjectStore>) root withCache:(BOOL) cache;

//-------------------------
//
// Methods
//
//-------------------------s
-(MHVTypeView *) getView:(NSString *) name;
-(BOOL) putView:(MHVTypeView *) view name:(NSString*) name;
-(void) deleteView:(NSString *) name;

-(NSData *) getPersonalImage;
-(BOOL) putPersonalImage:(NSData *) imageData;
-(void) deletePersonalImage;

-(MHVStoredQuery *) getStoredQuery:(NSString *) name;
-(BOOL) putStoredQuery:(MHVStoredQuery *) query withName:(NSString *) name;
-(void) deleteStoredQuery:(NSString *) name;

-(MHVSynchronizedType *) getSynchronizedTypeForTypeID:(NSString *) typeID;

+(NSString *) metadataStoreKey;

-(BOOL) resetMetadata;
-(BOOL) resetData;

-(void) clearCache;
//
// If you are using Offline changes, call this to commit all pending changes to HealthVault
//
-(MHVTask *) commitOfflineChangesWithCallback:(MHVTaskCompletion) callback;

//
// Must be called to close references
//
-(void) close;

@end

