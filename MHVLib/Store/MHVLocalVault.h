//
//  MHVLocalVault.h
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
#import "MHVDirectory.h"
#import "MHVObjectStore.h"
#import "MHVLocalRecordStore.h"
#import "MHVLocalVocabStore.h"

//-------------------------
//
// The LocalVault is a simple, readymade store
// that uses the local FILESYSTEM for storage
// You can use it to store Vocabs, Things, Blobs, Xml Setttings etc. 
// 
//-------------------------

@interface MHVLocalVault : NSObject
{
    MHVDirectory* m_root;
    NSMutableDictionary* m_recordStores;
    MHVLocalVocabStore* m_vocabs;
    BOOL m_cache;
}

@property (strong, readonly, nonatomic) id<MHVObjectStore> root;
@property (strong, readonly, nonatomic) MHVLocalVocabStore* vocabs;

//-------------------------
//
// Initializers
//
//-------------------------
//
// No caching by default
//
-(id) initWithRoot:(MHVDirectory *) root;
-(id) initWithRoot:(MHVDirectory *) root andCache:(BOOL) cache;

//-------------------------
//
// Methods
//
//-------------------------
//
// Return a record store for the given record
//
-(MHVLocalRecordStore *) getRecordStore:(MHVRecordReference *) record;
-(BOOL) deleteRecordStore:(MHVRecordReference *) record;

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
-(MHVTask *) commitOfflineChangesWithCallback:(MHVTaskCompletion) callback;

@end
