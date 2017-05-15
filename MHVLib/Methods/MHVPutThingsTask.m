//
//  MHVPutThingsTask.m
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
#import "MHVPutThingsTask.h"
#import "MHVClient.h"

@implementation MHVPutThingsTask

-(BOOL)hasThings
{
    return ![MHVCollection isNilOrEmpty:m_things];
}

-(MHVThingCollection *)things
{
    if (!m_things)
    {
        m_things = [[MHVThingCollection alloc] init];
    }
    
    return m_things;
}

-(void)setThings:(MHVThingCollection *)things
{
    m_things = things;
}

-(MHVThingKeyCollection *) putResults
{
    return (MHVThingKeyCollection *) self.result;
}

-(MHVThingKey *)firstKey
{
    MHVThingKeyCollection* results = self.putResults;
    return (![MHVCollection isNilOrEmpty:results]) ? [results objectAtIndex:0] : nil;
}

-(NSString *)name
{
    return @"PutThings";
}

-(float)version
{
    return 2;
}

-(id)initWithThing:(MHVThing *)thing andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(thing);
    
    MHVThingCollection* things = [[MHVThingCollection alloc]initWithThing:thing];
    self = [self initWithThings:things andCallback:callback];
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithThings:(MHVThingCollection *)things andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_TRUE((![MHVCollection isNilOrEmpty:things]));
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    self.things = things;
    
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
    for (NSUInteger i = 0, count = m_things.count; i < count; ++i)
    {
        MHVThing* thing = [m_things objectAtIndex:i];
        [self validateObject:thing];
        [XSerializer serialize:thing withRoot:@"thing" toWriter:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVThingKeyCollection class]];
}

+(MHVPutThingsTask *)newForRecord:(MHVRecordReference *)record thing:(MHVThing *)thing andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVPutThingsTask* task = [[MHVPutThingsTask alloc] initWithThing:thing andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

+(MHVPutThingsTask *) newForRecord:(MHVRecordReference *) record things:(MHVThingCollection *)things andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVPutThingsTask* task = [[MHVPutThingsTask alloc] initWithThings:things andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
