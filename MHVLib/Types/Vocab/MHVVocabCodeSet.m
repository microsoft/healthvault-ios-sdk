//
//  HVVocabSearchResult.m
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
#import "MHVVocabCodeSet.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_family = @"family";
static NSString* const c_element_version = @"version";
static NSString* const c_element_item = @"code-item";
static NSString* const c_element_truncated = @"is-vocab-truncated";

@implementation MHVVocabCodeSet

@synthesize name = m_name;
@synthesize family = m_family;
@synthesize version = m_version;
@synthesize isTruncated = m_isTruncated;

-(BOOL)hasItems
{
    return (![NSArray isNilOrEmpty:m_items]);
}

-(MHVVocabItemCollection *)items
{
    HVENSURE(m_items, MHVVocabItemCollection);
    return m_items;
}

-(void)setItems:(MHVVocabItemCollection *)items
{
    m_items = items;
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


-(MHVVocabIdentifier *)getVocabID
{
    return [[MHVVocabIdentifier alloc] initWithFamily:m_family andName:m_name];
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
    m_name = [reader readStringElement:c_element_name];
    m_family = [reader readStringElement:c_element_family];
    m_version = [reader readStringElement:c_element_version];
    m_items = (MHVVocabItemCollection *)[reader readElementArray:c_element_item asClass:[MHVVocabItem class] andArrayClass:[MHVVocabItemCollection class]];
    m_isTruncated = [reader readElement:c_element_truncated asClass:[MHVBool class]];
}

@end

@implementation MHVVocabSetCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVVocabCodeSet class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(MHVVocabCodeSet *)itemAtIndex:(NSUInteger)index
{
    return (MHVVocabCodeSet *) [super objectAtIndex:index];
}

@end

static NSString* const c_element_codeset = @"code-set-result";

@implementation MHVVocabSearchResults

@synthesize match = m_match;

-(BOOL)hasMatches
{
    return (m_match != nil);
}


-(void)serialize:(XWriter *)writer  
{
    [writer writeElement:c_element_codeset content:m_match];
}

-(void)deserialize:(XReader *)reader
{
    m_match = [reader readElement:c_element_codeset asClass:[MHVVocabCodeSet class]];
}

@end


