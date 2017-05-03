//
//  MHVItemKey.m
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
#import "MHVItemKey.h"
#import "MHVValidator.h"
#import "MHVGuid.h"

static const xmlChar* x_attribute_version = XMLSTRINGCONST("version-stamp");
static NSString* const c_localIDPrefix = @"L";

@implementation MHVItemKey

@synthesize itemID = m_id;
@synthesize version = m_version;

-(BOOL)hasVersion
{
    return (![NSString isNilOrEmpty:m_version]);
}

-(id)initWithID:(NSString *)itemID
{
    return [self initWithID:itemID andVersion:nil];
}

-(id) initWithID:(NSString *)itemID andVersion:(NSString *)version
{
    HVCHECK_NOTNULL(itemID);
     
    self = [super init];
    HVCHECK_SELF;
    
    self.itemID = itemID;
    if (version)
    {
        self.version = version;
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;    
}

-(id)initWithKey:(MHVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    return [self initWithID:key.itemID andVersion:key.version];

LError:
    HVALLOC_FAIL;
}

-(id) initNew
{
    return [self initWithID:[[NSUUID UUID] UUIDString]];
}


+(MHVItemKey *)newLocal
{
    NSString* itemID =  [c_localIDPrefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
    NSString* version = [[NSUUID UUID] UUIDString];
    
    return [[MHVItemKey alloc] initWithID:itemID andVersion:version];
}

+(MHVItemKey *)local
{
    return [MHVItemKey newLocal];
}

-(BOOL)isVersion:(NSString *)version
{
    return [self.version isEqualToString:version];
}

-(BOOL)isLocal
{
    return [m_id hasPrefix:c_localIDPrefix];
}

-(BOOL)isEqualToKey:(MHVItemKey *)key
{
    if (!key)
    {
        return FALSE;
    }
    
    
    return ([m_id isEqualToString:key.itemID] &&
            (m_version && key.version) &&
            [m_version isEqualToString:key.version]
            );
}

-(MHVClientResult *) validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRING(m_id, HVClientError_InvalidItemKey);
    HVVALIDATE_STRING(m_version, HVClientError_InvalidItemKey);
    
    HVVALIDATE_SUCCESS
}

-(NSString *)description
{
    return m_id;
}

-(void) serializeAttributes:(XWriter *)writer
{
    [writer writeAttributeXmlName:x_attribute_version value:m_version];
}

-(void) serialize:(XWriter *)writer
{
    [writer writeText:m_id];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_version = [reader readAttributeWithXmlName:x_attribute_version];
}

-(void) deserialize:(XReader *)reader
{
    m_id = [reader readValue];
}

@end

static NSString* const c_element_key = @"thing-id";

@implementation MHVItemKeyCollection

-(id) init
{
    return [self initWithKey:nil];
}

-(id)initWithKey:(MHVItemKey *)key
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVItemKey class];
    if (key)
    {
        [self addObject:key];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(MHVItemKey *)key
{
    [super addObject:key];
}

-(MHVItemKey *)firstKey
{
    return [self itemAtIndex:0];
}

-(MHVItemKey *)itemAtIndex:(NSUInteger)index
{
    return (MHVItemKey *) [self objectAtIndex:index];
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_inner, HVClientError_InvalidItemList);
    
    HVVALIDATE_SUCCESS
}

-(void)serializeAttributes:(XWriter *)writer
{
    
}
-(void)deserializeAttributes:(XReader *)reader
{
    
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_key elements:m_inner];
}

-(void)deserialize:(XReader *)reader
{
    m_inner = [reader readElementArray:c_element_key asClass:[MHVItemKey class]];
}

@end
