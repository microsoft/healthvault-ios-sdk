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
    HVRETAIN(m_items, items);
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

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_name, c_element_name);
    HVSERIALIZE_STRING(m_family, c_element_family);
    HVSERIALIZE_STRING(m_version, c_element_version);
    HVSERIALIZE_ARRAY(m_items, c_element_item);
    HVSERIALIZE(m_isTruncated, c_element_truncated);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_name, c_element_name);
    HVDESERIALIZE_STRING(m_family, c_element_family);
    HVDESERIALIZE_STRING(m_version, c_element_version);
    HVDESERIALIZE_TYPEDARRAY(m_items, c_element_item, HVVocabItem, HVVocabItemCollection);
    HVDESERIALIZE(m_isTruncated, c_element_truncated, HVBool);
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
    HVSERIALIZE(m_match, c_element_codeset);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_match, c_element_codeset, HVVocabCodeSet);
}

@end


static NSString* const c_element_vocab = @"vocabulary";

@implementation HVVocabGetResults

@synthesize vocab = m_vocab;

-(void)dealloc
{
    [m_vocab release];
    [super dealloc];
}

-(void)serialize:(XWriter *)writer  
{
    HVSERIALIZE(m_vocab, c_element_vocab);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_vocab, c_element_vocab, HVVocabCodeSet);
}

@end

