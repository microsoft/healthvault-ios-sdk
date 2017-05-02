//
//  HVStoredQuery.m
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
//
#import "HVCommon.h"
#import "HVStoredQuery.h"
#import "HVClient.h"

static NSString* const c_element_query = @"query";
static NSString* const c_element_result = @"result";
static NSString* const c_element_timestamp = @"timestamp";

@interface HVStoredQuery (HVPrivate)

-(void) getItemsComplete:(HVTask *) task forRecord:(HVRecordReference *) record;

@end

@implementation HVStoredQuery

@synthesize query = m_query;

-(HVItemQueryResult *)result
{
    return m_result;
}

-(void)setResult:(HVItemQueryResult *)result
{
    m_result = [result retain];
    self.timestamp = [NSDate date];
}

@synthesize timestamp = m_timestamp;

-(void)dealloc
{
    [m_query release];
    [m_result release];
    [m_timestamp release];
    
    [super dealloc];
}

-(id)initWithQuery:(HVItemQuery *)query
{
    return [self initWithQuery:query andResult:nil];
}

-(id)initWithQuery:(HVItemQuery *)query andResult:(HVItemQueryResult *)result
{
    HVCHECK_NOTNULL(query);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.query = query;
    self.result = result;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(BOOL)isStale:(NSTimeInterval) maxAge
{
    NSDate* now = [NSDate date];
    return ([now timeIntervalSinceDate:m_timestamp] > maxAge);
}

-(HVTask *)synchronizeForRecord:(HVRecordReference *)record withCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(m_query);
    HVCHECK_NOTNULL(record);
    
    HVTask* task = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);

    HVGetItemsTask* getItemsTask = [[[HVClient current].methodFactory newGetItemsForRecord:record query:m_query andCallback:^(HVTask *task) {
        [self getItemsComplete:task forRecord:record];
    }] autorelease];
    HVCHECK_NOTNULL(getItemsTask);
    
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
    m_timestamp = [[reader readDateElement:c_element_timestamp] retain];
    m_query = [[reader readElement:c_element_query asClass:[HVItemQuery class]] retain];
    m_result = [[reader readElement:c_element_result asClass:[HVItemQueryResult class]] retain];    
}

@end

@implementation HVStoredQuery (HVPrivate)

-(void)getItemsComplete:(HVTask *)task forRecord:(HVRecordReference *)record
{
    HVItemQueryResult* queryResult = ((HVGetItemsTask*) task).queryResult;
    if (!queryResult.hasPendingItems)
    {
        self.result = queryResult;
        return;
    }
    //
    // Populate the query result's pending items
    //
    HVTask* pendingItemsTask = [queryResult createTaskToGetPendingItemsForRecord:record itemView:m_query.view withCallback:^(HVTask *task) {
        
        [task checkSuccess];
        self.result = queryResult;
    }];
    
    [task.parent setNextTask:pendingItemsTask];
}

@end
