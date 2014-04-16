//
//  HVLocalVault.h
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
#import "HVDirectory.h"
#import "HVObjectStore.h"
#import "HVLocalRecordStore.h"
#import "HVLocalVocabStore.h"

//-------------------------
//
// The LocalVault is a simple, readymade store
// that uses the local FILESYSTEM for storage
// You can use it to store Vocabs, Items, Blobs, Xml Setttings etc. 
// 
//-------------------------

@interface HVLocalVault : NSObject
{
    HVDirectory* m_root;
    NSMutableDictionary* m_recordStores;
    HVLocalVocabStore* m_vocabs;
    BOOL m_cache;
}

@property (readonly, nonatomic) id<HVObjectStore> root;
@property (readonly, nonatomic) HVLocalVocabStore* vocabs;

//-------------------------
//
// Initializers
//
//-------------------------
//
// No caching by default
//
-(id) initWithRoot:(HVDirectory *) root;
-(id) initWithRoot:(HVDirectory *) root andCache:(BOOL) cache;

//-------------------------
//
// Methods
//
//-------------------------
//
// Return a record store for the given record
//
-(HVLocalRecordStore *) getRecordStore:(HVRecordReference *) record;
-(BOOL) deleteRecordStore:(HVRecordReference *) record;

-(void) resetDataStoreForRecords:(NSArray *) records;

//
// For memory management
//
-(void) didReceiveMemoryWarning;
-(void) clearCache;

//
// If you are using Offline changes, call this to commit all pending changes to HealthVault
// This will iterate over all local record stores and commit their changes one by one
//
-(HVTask *) commitOfflineChangesWithCallback:(HVTaskCompletion) callback;
-(HVTask *) commitOfflineChangesForRecords:(NSArray *) records withCallback:(HVTaskCompletion)callback;

@end
