//
//  HVItemData.m
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
#import "HVItemData.h"
#import "HVItemType.h"
#import "HVItemRaw.h"

static NSString* const c_element_common = @"common";

@interface HVItemData (HVPrivate)

-(HVItemDataTyped *) deserializeTyped:(XReader *) reader;
-(HVItemRaw *) deserializeRaw:(XReader *) reader;

@end

@implementation HVItemData

@synthesize common = m_common;
@synthesize typed = m_typed;

-(BOOL) hasTyped
{
    return (m_typed != nil);
}

-(HVItemDataTyped *) typed
{
    HVENSURE(m_typed, HVItemDataTyped);
    return m_typed;
}

-(void) setTyped:(HVItemDataTyped *)typed
{
    HVRETAIN(m_typed, typed);
}

-(BOOL) hasCommon
{
    return (m_common != nil);
}

-(HVItemDataCommon *) common
{
    HVENSURE(m_common, HVItemDataCommon);
    return m_common;
}

-(void) setCommon:(HVItemDataCommon *)common
{
    HVRETAIN(m_common, common);
}

-(void) dealloc
{
    [m_common release];
    [m_typed release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_common);
    HVVALIDATE_OPTIONAL(m_typed);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void) serialize:(XWriter *)writer
{
    if (m_typed)
    {
        [writer writeElement:m_typed.rootElement content:m_typed];
    }
    
    [writer writeElement:c_element_common content:m_common];
}

-(void) deserialize:(XReader *)reader
{
    if (![reader isStartElementWithName:c_element_common])
    {
        //
        // Typed Item Data!
        //
        m_typed = [self deserializeTyped:reader];
        if (!m_typed)
        {
            m_typed = [self deserializeRaw:reader];
        }
        HVCHECK_OOM(m_typed);
    }
    
    if ([reader isStartElementWithName:c_element_common])
    {
        m_common = [[reader readElement:c_element_common asClass:[HVItemDataCommon class]] retain];
    }
}

@end

@implementation HVItemData (HVPrivate)

-(HVItemDataTyped *) deserializeTyped:(XReader *)reader
{
    HVItemType* itemType = (HVItemType *) reader.context;
    NSString* typeID = (itemType != nil) ? itemType.typeID : nil;
    
    HVItemDataTyped* typedItem = [[HVTypeSystem current] newFromTypeID:typeID];
    if (typedItem)
    {
        if (typedItem.hasRawData)
        {
            [typedItem deserialize:reader];
        }
        else 
        {
            [reader readElementRequired:reader.localName intoObject:typedItem];
        }
    }
    
    return typedItem;
}

-(HVItemRaw *)deserializeRaw:(XReader *)reader
{
    HVItemRaw* raw = [[HVItemRaw alloc] init];
    if (raw)
    {
        [raw deserialize:reader];
    }
    
    return raw;
}

@end
