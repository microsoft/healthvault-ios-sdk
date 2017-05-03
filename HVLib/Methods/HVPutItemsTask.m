//
//  HVPutItemsTask.m
//  HVLib
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

#import "HVCommon.h"
#import "HVPutItemsTask.h"
#import "HVClient.h"

@implementation HVPutItemsTask

-(BOOL)hasItems
{
    return ![NSArray isNilOrEmpty:m_items];
}

-(HVItemCollection *)items
{
    HVENSURE(m_items, HVItemCollection);
    return m_items;
}

-(void)setItems:(HVItemCollection *)items
{
    m_items = items;
}

-(HVItemKeyCollection *) putResults
{
    return (HVItemKeyCollection *) self.result;
}

-(HVItemKey *)firstKey
{
    HVItemKeyCollection* results = self.putResults;
    return (![NSArray isNilOrEmpty:results]) ? [results itemAtIndex:0] : nil;
}

-(NSString *)name
{
    return @"PutThings";
}

-(float)version
{
    return 2;
}

-(id)initWithItem:(HVItem *)item andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(item);
    
    HVItemCollection* items = [[HVItemCollection alloc]initWithItem:item];
    self = [self initWithItems:items andCallback:callback];
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItems:(HVItemCollection *)items andCallback:(HVTaskCompletion)callback
{
    HVCHECK_TRUE((![NSArray isNilOrEmpty:items]));
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.items = items;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(void)prepare
{
    [self ensureRecord];
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    for (NSUInteger i = 0, count = m_items.count; i < count; ++i)
    {
        HVItem* item = [m_items objectAtIndex:i];
        [self validateObject:item];
        [XSerializer serialize:item withRoot:@"thing" toWriter:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[HVItemKeyCollection class]];
}

+(HVPutItemsTask *)newForRecord:(HVRecordReference *)record item:(HVItem *)item andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    HVPutItemsTask* task = [[HVPutItemsTask alloc] initWithItem:item andCallback:callback];
    HVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

+(HVPutItemsTask *) newForRecord:(HVRecordReference *) record items:(HVItemCollection *)items andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    HVPutItemsTask* task = [[HVPutItemsTask alloc] initWithItems:items andCallback:callback];
    HVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
