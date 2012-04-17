//
//  HVItemQueryResult.m
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
#import "HVItemQueryResult.h"

static NSString* const c_element_item = @"thing";
static NSString* const c_element_pending = @"unprocessed-thing-key-info";
static NSString* const c_attribute_name = @"name";

@implementation HVItemQueryResult

@synthesize items = m_items;
@synthesize pendingItems = m_pendingItems;
@synthesize name = m_name;

-(BOOL) hasItems
{
    return !([NSArray isNilOrEmpty:m_items]);
}

-(BOOL) hasPendingItems
{
    return !([NSArray isNilOrEmpty:m_pendingItems]);
}

-(void) dealloc
{
    [m_items release];
    [m_pendingItems release];
    [m_name release];
    [super dealloc];
}

-(void) serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_items, c_element_item);
    HVSERIALIZE_ARRAY(m_pendingItems, c_element_pending);
}

-(void) deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_items, c_element_item, HVItem, HVItemCollection);
    HVDESERIALIZE_TYPEDARRAY(m_pendingItems, c_element_pending, HVPendingItem, HVPendingItemCollection);
}

@end

@implementation HVItemQueryResultCollection 

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVItemQueryResult class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end


