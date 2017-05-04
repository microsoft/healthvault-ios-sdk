//
//  MHVPutItemsTask.m
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
#import "MHVPutItemsTask.h"
#import "MHVClient.h"

@implementation MHVPutItemsTask

-(BOOL)hasItems
{
    return ![NSArray isNilOrEmpty:m_items];
}

-(MHVItemCollection *)items
{
    MHVENSURE(m_items, MHVItemCollection);
    return m_items;
}

-(void)setItems:(MHVItemCollection *)items
{
    m_items = items;
}

-(MHVItemKeyCollection *) putResults
{
    return (MHVItemKeyCollection *) self.result;
}

-(MHVItemKey *)firstKey
{
    MHVItemKeyCollection* results = self.putResults;
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

-(id)initWithItem:(MHVItem *)item andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(item);
    
    MHVItemCollection* items = [[MHVItemCollection alloc]initWithItem:item];
    self = [self initWithItems:items andCallback:callback];
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItems:(MHVItemCollection *)items andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_TRUE((![NSArray isNilOrEmpty:items]));
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    self.items = items;
    
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
    for (NSUInteger i = 0, count = m_items.count; i < count; ++i)
    {
        MHVItem* item = [m_items objectAtIndex:i];
        [self validateObject:item];
        [XSerializer serialize:item withRoot:@"thing" toWriter:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVItemKeyCollection class]];
}

+(MHVPutItemsTask *)newForRecord:(MHVRecordReference *)record item:(MHVItem *)item andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVPutItemsTask* task = [[MHVPutItemsTask alloc] initWithItem:item andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

+(MHVPutItemsTask *) newForRecord:(MHVRecordReference *) record items:(MHVItemCollection *)items andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVPutItemsTask* task = [[MHVPutItemsTask alloc] initWithItems:items andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
