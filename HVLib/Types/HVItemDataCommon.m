//
//  HVItemDataCommon.m
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
#import "HVItemDataCommon.h"

static NSString* const c_element_source = @"source";
static NSString* const c_element_note = @"note";
static NSString* const c_element_tags = @"tags";
static NSString* const c_element_extension = @"extension";
static NSString* const c_element_related = @"related-thing";
static NSString* const c_element_clientID = @"client-thing-id";

@implementation HVItemDataCommon

@synthesize source = m_source;
@synthesize note = m_note;
@synthesize tags = m_tags;
@synthesize extensions = m_extensions;
@synthesize relatedItems = m_relatedItems;
@synthesize clientID = m_clientID;
-(NSString *)clientIDValue
{
    return m_clientID ? m_clientID.value : nil;
}
-(void)setClientIDValue:(NSString *)clientIDValue
{
    HVCLEAR(m_clientID);
    if (![NSString isNilOrEmpty:clientIDValue])
    {
        HVString255* clientID = [[HVString255 alloc] initWith:clientIDValue];
        HVRETAIN(m_clientID, clientID);
        [clientID release];
    }
}

-(void) dealloc
{
    [m_source release];
    [m_note release];
    [m_tags release];
    [m_extensions release];
    [m_relatedItems release];
    [m_clientID release];
    
    [super dealloc];
}

-(HVRelatedItem *)addRelation:(NSString *)name toItem:(HVItem *)item
{
    HVENSURE(m_relatedItems, HVRelatedItemCollection);
    return [m_relatedItems addRelation:name toItem:item];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_OPTIONAL(m_tags);
    HVVALIDATE_ARRAYOPTIONAL(m_relatedItems, HVClientError_InvalidRelatedItem);
    HVVALIDATE_OPTIONAL(m_clientID);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_source, c_element_source);
    HVSERIALIZE_STRING(m_note, c_element_note);
    HVSERIALIZE(m_tags, c_element_tags);
    HVSERIALIZE_RAWARRAY(m_extensions, c_element_extension);
    HVSERIALIZE_ARRAY(m_relatedItems, c_element_related);
    HVSERIALIZE(m_clientID, c_element_clientID);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_source, c_element_source);
    HVDESERIALIZE_STRING(m_note, c_element_note);
    HVDESERIALIZE(m_tags, c_element_tags, HVStringZ512);
    HVDESERIALIZE_RAWARRAY(m_extensions, c_element_extension);
    HVDESERIALIZE_TYPEDARRAY(m_relatedItems, c_element_related, HVRelatedItem, HVRelatedItemCollection);
    HVDESERIALIZE(m_clientID, c_element_clientID, HVString255);
}

@end
