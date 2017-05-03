//
//  MHVRelatedItem.m
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
#import "MHVRelatedItem.h"
#import "MHVItem.h"

static NSString* const c_element_thingID = @"thing-id";
static NSString* const c_element_version = @"version-stamp";
static NSString* const c_element_clientID = @"client-thing-id";
static NSString* const c_element_relationship = @"relationship-type";

@implementation MHVRelatedItem

@synthesize itemID = m_itemID;
@synthesize version = m_version;
@synthesize clientID = m_clientID;
@synthesize relationship = m_relationship;


-(id)initRelationship:(NSString *)relationship toItemWithKey:(MHVItemKey *)key
{
    HVCHECK_STRING(relationship);
    HVCHECK_NOTNULL(key);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.itemID = key.itemID;
    self.version = key.version;
    self.relationship = relationship;
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(id)initRelationship:(NSString *)relationship toItemWithClientID:(NSString *)clientID  
{
    HVCHECK_STRING(relationship);
    HVCHECK_STRING(clientID);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.relationship = relationship;
    
    m_clientID = [[MHVString255 alloc] initWith:clientID];
    HVCHECK_NOTNULL(m_clientID);
    
    return self;
    
LError:
    HVALLOC_FAIL;
    
}


-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE_STRINGOPTIONAL(m_itemID, HVClientError_InvalidRelatedItem);
    HVVALIDATE_OPTIONAL(m_clientID);
    HVVALIDATE_STRINGOPTIONAL(m_relationship, HVClientError_InvalidRelatedItem);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_thingID value:m_itemID];
    [writer writeElement:c_element_version value:m_version];
    [writer writeElement:c_element_clientID content:m_clientID];
    [writer writeElement:c_element_relationship value:m_relationship];
}

-(void)deserialize:(XReader *)reader
{
    m_itemID = [reader readStringElement:c_element_thingID];
    m_version = [reader readStringElement:c_element_version];
    m_clientID = [reader readElement:c_element_clientID asClass:[MHVString255 class]];
    m_relationship = [reader readStringElement:c_element_relationship];
}

+(MHVRelatedItem *)relationNamed:(NSString *)name toItem:(MHVItem *)item
{
    return [MHVRelatedItem relationNamed:name toItemKey:item.key];
}

+(MHVRelatedItem *)relationNamed:(NSString *)name toItemKey:(MHVItemKey *)key
{
    return [[MHVRelatedItem alloc] initRelationship:name toItemWithKey:key];
}

@end

@implementation MHVRelatedItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVRelatedItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSUInteger)indexOfRelation:(NSString *)name
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        MHVRelatedItem* item = (MHVRelatedItem *) [self objectAtIndex:i];
        if (item.relationship && [item.relationship isEqualToStringCaseInsensitive:name])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(MHVRelatedItem *)addRelation:(NSString *)name toItem:(MHVItem *)item
{
    MHVRelatedItem* relation = [MHVRelatedItem relationNamed:name toItem:item];
    HVCHECK_NOTNULL(relation);
    
    [self addObject:relation];
    
    return relation;

LError:
    return nil;
}

@end
