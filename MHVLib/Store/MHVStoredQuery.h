//
//  MHVStoredQuery.h
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

#import <Foundation/Foundation.h>
#import "XLib.h"
#import "MHVTypes.h"

@interface MHVStoredQuery : XSerializableType
{
@private
    MHVItemQuery* m_query;
    MHVItemQueryResult* m_result;
    NSDate* m_timestamp;
}

@property (readwrite, nonatomic, strong) MHVItemQuery* query;
@property (readwrite, nonatomic, strong) MHVItemQueryResult* result;
@property (readwrite, nonatomic, strong) NSDate* timestamp;

-(id) initWithQuery:(MHVItemQuery *) query;
-(id) initWithQuery:(MHVItemQuery *) query andResult:(MHVItemQueryResult *) result;

//
// maxAgeInSeconds
//
-(BOOL) isStale:(NSTimeInterval) maxAge;

-(MHVTask *) synchronizeForRecord:(MHVRecordReference *) record withCallback:(MHVTaskCompletion) callback;

@end
