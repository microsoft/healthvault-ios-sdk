//
//  HVItemKey.m
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
#import "HVItemKey.h"
#import "HVValidator.h"
#import "HVGuid.h"

static NSString* const c_attribute_version = @"version-stamp";

@implementation HVItemKey

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

-(id)initWithKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    return [self initWithID:key.itemID andVersion:key.version];

LError:
    HVALLOC_FAIL;
}

-(id) initNew
{
    return [self initWithID:guidString()];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRING(m_id, HVClientError_InvalidItemKey);
    HVVALIDATE_STRING(m_version, HVClientError_InvalidItemKey);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void) dealloc
{
    [m_id release];
    [m_version release];
    
    [super dealloc];
}

-(NSString *)description
{
    return m_id;
}

-(void) serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE(m_version, c_attribute_version);
}
-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_TEXT(m_id);
}

-(void) deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE(m_version, c_attribute_version);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TEXT(m_id);
}

@end

static NSString* const c_element_key = @"thing-id";

@implementation HVItemKeyCollection

-(id) init
{
    return [self initWithKey:nil];
}

-(id)initWithKey:(HVItemKey *)key
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVItemKey class];
    if (key)
    {
        [self addObject:key];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_inner, HVClientError_InvalidItemList);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serializeAttributes:(XWriter *)writer
{
    
}
-(void)deserializeAttributes:(XReader *)reader
{
    
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_inner, c_element_key);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_ARRAY(m_inner, c_element_key, HVItemKey);
}

@end
