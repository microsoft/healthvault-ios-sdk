//
//  HVTypeViewRefresher.h
//  HVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

//
// Efficiently refreshes multiple HVTypeViews with minimal round trips.
// Only views that are:
//  - Stale
//  - Don't have pending changes
//
@interface HVMultipleTypeViewRefresher : NSObject
{
@private
    HVRecordReference* m_record;
    NSMutableDictionary* m_views;
    NSTimeInterval m_maxAge;
}

@property (readwrite, nonatomic) NSTimeInterval maxAge;

//
// Supply an array of objects that adopt the id<HVTypeView> protocol
// Those views that are now stale will be refreshed
//
-(id) initWithRecord:(HVRecordReference *) record views:(NSArray *) views andMaxAge:(NSTimeInterval) age;
-(id) initWithRecordStore:(HVLocalRecordStore *) store synchronizedTypeIDs:(NSArray *) typeIDs andMaxAge:(NSTimeInterval) age;
//
// Returns nil if no refresh was triggered. Else returns a task object
//
-(HVTask *) refreshWithCallback:(HVTaskCompletion) callback;

@end
