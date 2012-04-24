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

@interface HVLocalRecordStore : NSObject 
{
@private
    HVRecordReference* m_record;
    id<HVObjectStore> m_root;
    id<HVObjectStore> m_metadata;
    HVSynchronizedStore* m_data;   
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
// Metadata, such as view definitions, etc..
//
@property (readonly, nonatomic) id<HVObjectStore> metadata;
//
// Item Data stored here (Xml)
//
@property (readonly, nonatomic) HVSynchronizedStore* data;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initForRecord:(HVRecordReference *) record overRoot:(id<HVObjectStore>) root;

//-------------------------
//
// Methods
//
//-------------------------s
-(HVTypeView *) loadView:(NSString *) name;
-(BOOL) saveView:(HVTypeView *) view name:(NSString*) name;
-(void) deleteView:(NSString *) name;

-(NSData *) getPersonalImage;
-(BOOL) putPersonalImage:(NSData *) imageData;
-(void) deletePersonalImage;

@end
