//
//  MHVStoredQuery.m
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
#import "MHVCommon.h"
#import "MHVStoredQuery.h"
#import "MHVClient.h"

static NSString* const c_element_query = @"query";
static NSString* const c_element_result = @"result";
static NSString* const c_element_timestamp = @"timestamp";

@interface MHVStoredQuery (MHVPrivate)

-(void) getItemsComplete:(MHVTask *) task forRecord:(MHVRecordReference *) record;

@end

@implementation MHVStoredQuery

@synthesize query = m_query;

-(MHVItemQueryResult *)result
{
    return m_result;
}

-(void)setResult:(MHVItemQueryResult *)result
{
    m_result = result;
    self.timestamp = [NSDate date];
}

@synthesize timestamp = m_timestamp;


-(id)initWithQuery:(MHVItemQuery *)query
{
    return [self initWithQuery:query andResult:nil];
}

-(id)initWithQuery:(MHVItemQuery *)query andResult:(MHVItemQueryResult *)result
{
    MHVCHECK_NOTNULL(query);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.query = query;
    self.result = result;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(BOOL)isStale:(NSTimeInterval) maxAge
{
    NSDate* now = [NSDate date];
    return ([now timeIntervalSinceDate:m_timestamp] > maxAge);
}

-(MHVTask *)synchronizeForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(m_query);
    MHVCHECK_NOTNULL(record);
    
    MHVTask* task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);

    MHVGetItemsTask* getItemsTask = [[MHVClient current].methodFactory newGetItemsForRecord:record query:m_query andCallback:^(MHVTask *task) {
        [self getItemsComplete:task forRecord:record];
    }];
    MHVCHECK_NOTNULL(getItemsTask);
    
    [task setNextTask:getItemsTask];
    [task start];
    
    return task;
    
LError:
    return nil;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_timestamp dateValue:m_timestamp];
    [writer writeElement:c_element_query content:m_query];
    [writer writeElement:c_element_result content:m_result];
}

-(void)deserialize:(XReader *)reader
{
    m_timestamp = [reader readDateElement:c_element_timestamp];
    m_query = [reader readElement:c_element_query asClass:[MHVItemQuery class]];
    m_result = [reader readElement:c_element_result asClass:[MHVItemQueryResult class]];    
}

@end

@implementation MHVStoredQuery (MHVPrivate)

-(void)getItemsComplete:(MHVTask *)task forRecord:(MHVRecordReference *)record
{
    MHVItemQueryResult* queryResult = ((MHVGetItemsTask*) task).queryResult;
    if (!queryResult.hasPendingItems)
    {
        self.result = queryResult;
        return;
    }
    //
    // Populate the query result's pending items
    //
    MHVTask* pendingItemsTask = [queryResult createTaskToGetPendingItemsForRecord:record itemView:m_query.view withCallback:^(MHVTask *task) {
        
        [task checkSuccess];
        self.result = queryResult;
    }];
    
    [task.parent setNextTask:pendingItemsTask];
}

@end
