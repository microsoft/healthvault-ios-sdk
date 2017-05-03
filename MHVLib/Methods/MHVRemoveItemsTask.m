//
//  MHVRemoveItemsTask.m
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
#import "MHVRemoveItemsTask.h"

@implementation MHVRemoveItemsTask

-(BOOL)hasKeys
{
    return ![NSArray isNilOrEmpty:m_keys];
}

-(MHVItemKeyCollection *)keys
{
    HVENSURE(m_keys, MHVItemKeyCollection);
    return m_keys;
}

-(void)setKeys:(MHVItemKeyCollection *)keys
{
    m_keys = keys;
}

-(NSString *)name
{
    return @"RemoveThings";
}

-(float)version
{
    return 1;
}

-(id)initWithKey:(MHVItemKey *)key andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(key);
    
    MHVItemKeyCollection* keys = [[MHVItemKeyCollection alloc] initWithKey:key];
    self = [self initWithKeys:keys andCallback:callback];
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithKeys:(MHVItemKeyCollection *)keys andCallback:(HVTaskCompletion)callback
{
    HVCHECK_TRUE((![NSArray isNilOrEmpty:keys]));
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.keys = keys;
    
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
    for (NSUInteger i = 0, count = m_keys.count; i < count; ++i)
    {
        MHVItemKey* key = [m_keys objectAtIndex:i];
        [self validateObject:key];
        [XSerializer serialize:key withRoot:@"thing-id" toWriter:writer];
    }
}

+(MHVRemoveItemsTask *)newForRecord:(MHVRecordReference *)record key:(MHVItemKey *)key callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    MHVRemoveItemsTask* task = [[MHVRemoveItemsTask alloc] initWithKey:key andCallback:callback];
    HVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

+(MHVRemoveItemsTask *)newForRecord:(MHVRecordReference *)record keys:(MHVItemKeyCollection *)keys andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    MHVRemoveItemsTask* task = [[MHVRemoveItemsTask alloc] initWithKeys:keys andCallback:callback];
    HVCHECK_NOTNULL(task);
    
    task.record = record;
    
    return task;
    
LError:
    return nil;
}

@end
