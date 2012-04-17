//
//  HVRelatedItem.m
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
#import "HVRelatedItem.h"

static NSString* const c_element_thingID = @"thing-id";
static NSString* const c_element_version = @"version-stamp";
static NSString* const c_element_clientID = @"client-thing-id";
static NSString* const c_element_relationship = @"relationship-type";

@implementation HVRelatedItem

@synthesize itemID = m_itemID;
@synthesize version = m_version;
@synthesize clientID = m_clientID;
@synthesize relationship = m_relationship;


-(id)initRelationship:(NSString *)relationship toItemWithKey:(HVItemKey *)key
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
    
    m_clientID = [[HVString255 alloc] initWith:clientID];
    HVCHECK_NOTNULL(m_clientID);
    
    return self;
    
LError:
    HVALLOC_FAIL;
    
}

-(void)dealloc
{
    [m_itemID release];
    [m_version release];
    [m_clientID release];
    [m_relationship release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE_STRINGOPTIONAL(m_itemID, HVClientError_InvalidRelatedItem);
    HVVALIDATE_OPTIONAL(m_clientID);
    HVVALIDATE_STRINGOPTIONAL(m_relationship, HVClientError_InvalidRelatedItem);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_itemID, c_element_thingID);
    HVSERIALIZE_STRING(m_version, c_element_version);
    HVSERIALIZE(m_clientID, c_element_clientID);
    HVSERIALIZE_STRING(m_relationship, c_element_relationship);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_itemID, c_element_thingID);
    HVDESERIALIZE_STRING(m_version, c_element_version);
    HVDESERIALIZE(m_clientID, c_element_clientID, HVString255);
    HVDESERIALIZE_STRING(m_relationship, c_element_relationship);
}

@end

@implementation HVRelatedItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVRelatedItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}
@end
