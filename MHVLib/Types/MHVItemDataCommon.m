//
//  MHVItemDataCommon.m
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
#import "MHVItemDataCommon.h"

static NSString* const c_element_source = @"source";
static NSString* const c_element_note = @"note";
static NSString* const c_element_tags = @"tags";
static NSString* const c_element_extension = @"extension";
static NSString* const c_element_related = @"related-thing";
static NSString* const c_element_clientID = @"client-thing-id";

@implementation MHVItemDataCommon

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
    m_clientID = nil;
    if (![NSString isNilOrEmpty:clientIDValue])
    {
        MHVString255* clientID = [[MHVString255 alloc] initWith:clientIDValue];
        m_clientID = clientID;
    }
}


-(MHVRelatedItem *)addRelation:(NSString *)name toItem:(MHVItem *)item
{
    MHVENSURE(m_relatedItems, MHVRelatedItemCollection);
    return [m_relatedItems addRelation:name toItem:item];
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_OPTIONAL(m_tags);
    MHVVALIDATE_ARRAYOPTIONAL(m_relatedItems, MHVClientError_InvalidRelatedItem);
    MHVVALIDATE_OPTIONAL(m_clientID);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElement:c_element_source value:m_source];
    [writer writeElement:c_element_note value:m_note];
    [writer writeElement:c_element_tags content:m_tags];
    [writer writeRawElementArray:c_element_extension elements:m_extensions];
    [writer writeElementArray:c_element_related elements:m_relatedItems.toArray];
    [writer writeElement:c_element_clientID content:m_clientID];
}

-(void) deserialize:(XReader *)reader
{
    m_source = [reader readStringElement:c_element_source];
    m_note = [reader readStringElement:c_element_note];
    m_tags = [reader readElement:c_element_tags asClass:[MHVStringZ512 class]];
    m_extensions = [reader readRawElementArray:c_element_extension];
    m_relatedItems = (MHVRelatedItemCollection *)[reader readElementArray:c_element_related asClass:[MHVRelatedItem class] andArrayClass:[MHVRelatedItemCollection class]];
    m_clientID = [reader readElement:c_element_clientID asClass:[MHVString255 class]];
}

@end
