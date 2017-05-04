//
//  GetItems.m
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

#import "MHVCommon.h"
#import "MHVGetItemsTask.h"
#import "MHVClient.h"

@implementation MHVGetItemsTask

-(MHVItemQueryCollection *)queries
{
    MHVENSURE(m_queries, MHVItemQueryCollection);
    return m_queries;
}

-(MHVItemQuery *)firstQuery
{
    if ([NSArray isNilOrEmpty:m_queries])
    {
        return nil;
    }
    
    return [m_queries itemAtIndex:0];
}

-(MHVItemQueryResults *)queryResults
{
    return (MHVItemQueryResults *) self.result;
}

-(MHVItemQueryResult *)queryResult
{
    MHVItemQueryResults* results = self.queryResults;
    return (results) ? results.firstResult : nil;
}

-(MHVItemCollection *) itemsRetrieved
{
    MHVItemQueryResult* result = self.queryResult;
    return (result) ? result.items : nil;
}

-(MHVItem *)firstItemRetrieved
{
    return (self.itemsRetrieved) ? [self.itemsRetrieved itemAtIndex:0] : nil;
}

-(NSString *)name
{
    return @"GetThings";
}

-(float)version
{
    return 3;
}

-(id)initWithQuery:(MHVItemQuery *)query andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(query);
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    [self.queries addObject:query];
    MHVCHECK_NOTNULL(m_queries);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithQueries:(MHVItemQueryCollection *)queries andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_TRUE(![NSArray isNilOrEmpty:queries]);
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    m_queries = queries;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)prepare
{
    [self ensureRecord];
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    for (NSUInteger i = 0, count = m_queries.count; i < count; ++i)
    {
        MHVItemQuery* query = [m_queries itemAtIndex:i];
        [self validateObject:query];
        [XSerializer serialize:query withRoot:@"group" toWriter:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVItemQueryResults class]];
}

+(MHVGetItemsTask *) newForRecord:(MHVRecordReference *) record query:(MHVItemQuery *)query andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVGetItemsTask* task = [[MHVGetItemsTask alloc] initWithQuery:query andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;

    return task;
    
LError:
    return nil;
}

+(MHVGetItemsTask *) newForRecord:(MHVRecordReference *)record queries:(MHVItemQueryCollection *)queries andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVGetItemsTask* task = [[MHVGetItemsTask alloc] initWithQueries:queries andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
