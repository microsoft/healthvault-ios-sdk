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

static NSString* const c_element_query = @"query";
static NSString* const c_element_result = @"result";
static NSString* const c_element_timestamp = @"timestamp";

@implementation HVStoredQuery

@synthesize query = m_query;
-(HVItemQueryResult *)result
{
    return m_result;
}

-(void)setResult:(HVItemQueryResult *)result
{
    HVRETAIN(m_result, result);
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
    
    HVGetItemsTask* getItemsTask = [[HVGetItemsTask alloc] initWithQuery:m_query andCallback:^(HVTask *task) {
        
        HVItemQueryResult* queryResult = ((HVGetItemsTask*) task).queryResult;
        self.result = queryResult;

        if (queryResult.hasPendingItems)
        {
            HVTask* pendingItemsTask = [queryResult createTaskToGetPendingItemsForRecord:record withCallback:^(HVTask *task) {
                
                [task checkSuccess];
                
            }];
            
            [task.parent setNextTask:pendingItemsTask];
        }
    } ];
    
    getItemsTask.record = record;
    [task setNextTask:getItemsTask];
    [task start];
    
    return task;
    
LError:
    return nil;
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_DATE(m_timestamp, c_element_timestamp);
    HVSERIALIZE(m_query, c_element_query);
    HVSERIALIZE(m_result, c_element_result);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_DATE(m_timestamp, c_element_timestamp);
    HVDESERIALIZE(m_query, c_element_query, HVItemQuery);
    HVDESERIALIZE(m_result, c_element_result, HVItemQueryResult);    
}

@end
