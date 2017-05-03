//
//  HVVocabSearchResult.m
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
#import "HVVocabCodeSet.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_family = @"family";
static NSString* const c_element_version = @"version";
static NSString* const c_element_item = @"code-item";
static NSString* const c_element_truncated = @"is-vocab-truncated";

@implementation HVVocabCodeSet

@synthesize name = m_name;
@synthesize family = m_family;
@synthesize version = m_version;
@synthesize isTruncated = m_isTruncated;

-(BOOL)hasItems
{
    return (![NSArray isNilOrEmpty:m_items]);
}

-(HVVocabItemCollection *)items
{
    HVENSURE(m_items, HVVocabItemCollection);
    return m_items;
}

-(void)setItems:(HVVocabItemCollection *)items
{
    m_items = [items retain];
}

-(NSArray *)displayStrings
{
    return (m_items) ? [m_items displayStrings] : nil;
}

-(void)sortItemsByDisplayText
{
    if (m_items)
    {
        [m_items sortByDisplayText];
    }
}

-(void)dealloc
{
    [m_name release];
    [m_family release];
    [m_version release];
    [m_items release];
    [m_isTruncated release];
    [super dealloc];
}

-(HVVocabIdentifier *)getVocabID
{
    return [[[HVVocabIdentifier alloc] initWithFamily:m_family andName:m_name] autorelease];
}
-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:m_name];
    [writer writeElement:c_element_family value:m_family];
    [writer writeElement:c_element_version value:m_version];
    [writer writeElementArray:c_element_item elements:m_items];
    [writer writeElement:c_element_truncated content:m_isTruncated];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readStringElement:c_element_name] retain];
    m_family = [[reader readStringElement:c_element_family] retain];
    m_version = [[reader readStringElement:c_element_version] retain];
    m_items = (HVVocabItemCollection *)[[reader readElementArray:c_element_item asClass:[HVVocabItem class] andArrayClass:[HVVocabItemCollection class]] retain];
    m_isTruncated = [[reader readElement:c_element_truncated asClass:[HVBool class]] retain];
}

@end

@implementation HVVocabSetCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVVocabCodeSet class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVVocabCodeSet *)itemAtIndex:(NSUInteger)index
{
    return (HVVocabCodeSet *) [super objectAtIndex:index];
}

@end

static NSString* const c_element_codeset = @"code-set-result";

@implementation HVVocabSearchResults

@synthesize match = m_match;

-(BOOL)hasMatches
{
    return (m_match != nil);
}

-(void)dealloc
{
    [m_match release];
    [super dealloc];
}

-(void)serialize:(XWriter *)writer  
{
    [writer writeElement:c_element_codeset content:m_match];
}

-(void)deserialize:(XReader *)reader
{
    m_match = [[reader readElement:c_element_codeset asClass:[HVVocabCodeSet class]] retain];
}

@end


