//
//  MHVItemData.m
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
#import "MHVItemData.h"
#import "MHVItemType.h"
#import "MHVItemRaw.h"

static NSString* const c_element_common = @"common";

@interface MHVItemData (MHVPrivate)

-(MHVItemDataTyped *) deserializeTyped:(XReader *) reader;
-(MHVItemRaw *) deserializeRaw:(XReader *) reader;

@end

@implementation MHVItemData

@synthesize common = m_common;
@synthesize typed = m_typed;

-(BOOL) hasTyped
{
    return (m_typed != nil);
}

-(MHVItemDataTyped *) typed
{
    MHVENSURE(m_typed, MHVItemDataTyped);
    return m_typed;
}

-(void) setTyped:(MHVItemDataTyped *)typed
{
    m_typed = typed;
}

-(BOOL) hasCommon
{
    return (m_common != nil);
}

-(MHVItemDataCommon *) common
{
    MHVENSURE(m_common, MHVItemDataCommon);
    return m_common;
}

-(void) setCommon:(MHVItemDataCommon *)common
{
    m_common = common;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_common);
    MHVVALIDATE_OPTIONAL(m_typed);
    
    MHVVALIDATE_SUCCESS
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
        MHVCHECK_OOM(m_typed);
    }
    
    if ([reader isStartElementWithName:c_element_common])
    {
        m_common = [reader readElement:c_element_common asClass:[MHVItemDataCommon class]];
    }
}

@end

@implementation MHVItemData (MHVPrivate)

-(MHVItemDataTyped *) deserializeTyped:(XReader *)reader
{
    MHVItemType* itemType = (MHVItemType *) reader.context;
    NSString* typeID = (itemType != nil) ? itemType.typeID : nil;
    
    MHVItemDataTyped* typedItem = [[MHVTypeSystem current] newFromTypeID:typeID];
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

-(MHVItemRaw *)deserializeRaw:(XReader *)reader
{
    MHVItemRaw* raw = [[MHVItemRaw alloc] init];
    if (raw)
    {
        [raw deserialize:reader];
    }
    
    return raw;
}

@end
