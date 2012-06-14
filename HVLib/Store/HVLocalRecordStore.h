//
//  HVLocalRecordStore.h
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
#import "HVObjectStore.h"
#import "HVLocalItemStore.h"

@class HVTypeView;
@class HVSynchronizedStore;
@class HVStoredQuery;

@interface HVLocalRecordStore : NSObject 
{
@private
    HVRecordReference* m_record;
    id<HVObjectStore> m_root;
    id<HVObjectStore> m_metadata;
    HVSynchronizedStore* m_data;  
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
@property (readonly, nonatomic) HVRecordReference* record;
//
// Root store for this record
//
@property (readonly, nonatomic) id<HVObjectStore> root;
//
// Metadata, such as view definitions, etc..
// Child of root
//
@property (readonly, nonatomic) id<HVObjectStore> metadata;
//
// Item Data stored here (Xml)
// Child of root
//
@property (readonly, nonatomic) HVSynchronizedStore* data;

//-------------------------
//
// Initializers
//
//-------------------------
//
// NO caching by default.
//
-(id) initForRecord:(HVRecordReference *) record overRoot:(id<HVObjectStore>) root;
-(id) initForRecord:(HVRecordReference *) record overRoot:(id<HVObjectStore>) root withCache:(BOOL) cache;

//-------------------------
//
// Methods
//
//-------------------------s
-(HVTypeView *) getView:(NSString *) name;
-(BOOL) putView:(HVTypeView *) view name:(NSString*) name;
-(void) deleteView:(NSString *) name;

-(NSData *) getPersonalImage;
-(BOOL) putPersonalImage:(NSData *) imageData;
-(void) deletePersonalImage;

-(HVStoredQuery *) getStoredQuery:(NSString *) name;
-(BOOL) putStoredQuery:(HVStoredQuery *) query withName:(NSString *) name;
-(void) deleteStoredQuery:(NSString *) name;

+(NSString *) metadataStoreKey;
+(NSString *) dataStoreKey;

-(BOOL) resetData;

@end
