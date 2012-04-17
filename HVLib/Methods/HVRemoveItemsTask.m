//
//  HVRemoveItemsTask.m
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

#import "HVCommon.h"
#import "HVRemoveItemsTask.h"

@implementation HVRemoveItemsTask

-(BOOL)hasKeys
{
    return ![NSArray isNilOrEmpty:m_keys];
}

-(HVItemKeyCollection *)keys
{
    HVENSURE(m_keys, HVItemKeyCollection);
    return m_keys;
}

-(void)setKeys:(HVItemKeyCollection *)keys
{
    HVRETAIN(m_keys, keys);
}

-(NSString *)name
{
    return @"RemoveThings";
}

-(float)version
{
    return 1;
}

-(id)initWithKeys:(HVItemKeyCollection *)keys andCallback:(HVTaskCompletion)callback
{
    HVCHECK_TRUE((![NSArray isNilOrEmpty:keys]));
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.keys = keys;
    
    return self;
    
LError:
    HVALLOC_FAIL;
   
}

-(void)dealloc
{
    [m_keys release];
    [super dealloc];
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    for (NSUInteger i = 0, count = m_keys.count; i < count; ++i)
    {
        HVItemKey* key = [m_keys objectAtIndex:i];
        [self validateObject:key];
        [XSerializer serialize:key withRoot:@"thing-id" toWriter:writer];
    }
}

@end
