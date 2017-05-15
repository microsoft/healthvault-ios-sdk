//
//  GetThings.m
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
#import "MHVGetThingsTask.h"
#import "MHVClient.h"

@implementation MHVGetThingsTask

-(MHVThingQueryCollection *)queries
{
    if (!m_queries)
    {
        m_queries = [[MHVThingQueryCollection alloc] init];
    }
    
    return m_queries;
}

-(MHVThingQuery *)firstQuery
{
    if ([MHVCollection isNilOrEmpty:m_queries])
    {
        return nil;
    }
    
    return [m_queries objectAtIndex:0];
}

-(MHVThingQueryResults *)queryResults
{
    return (MHVThingQueryResults *) self.result;
}

-(MHVThingQueryResult *)queryResult
{
    MHVThingQueryResults* results = self.queryResults;
    return (results) ? results.firstResult : nil;
}

-(MHVThingCollection *) thingsRetrieved
{
    MHVThingQueryResult* result = self.queryResult;
    return (result) ? result.things : nil;
}

-(MHVThing *)firstThingRetrieved
{
    return (self.thingsRetrieved) ? [self.thingsRetrieved objectAtIndex:0] : nil;
}

-(NSString *)name
{
    return @"GetThings";
}

-(float)version
{
    return 3;
}

-(id)initWithQuery:(MHVThingQuery *)query andCallback:(MHVTaskCompletion)callback
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

-(id)initWithQueries:(MHVThingQueryCollection *)queries andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_TRUE(![MHVCollection isNilOrEmpty:queries]);
    
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
        MHVThingQuery* query = [m_queries objectAtIndex:i];
        [self validateObject:query];
        [XSerializer serialize:query withRoot:@"group" toWriter:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVThingQueryResults class]];
}

+(MHVGetThingsTask *) newForRecord:(MHVRecordReference *) record query:(MHVThingQuery *)query andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVGetThingsTask* task = [[MHVGetThingsTask alloc] initWithQuery:query andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

+(MHVGetThingsTask *) newForRecord:(MHVRecordReference *)record queries:(MHVThingQueryCollection *)queries andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVGetThingsTask* task = [[MHVGetThingsTask alloc] initWithQueries:queries andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
