//
//  HVItemType.m
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
#import "HVItemType.h"

static NSString* const c_attribute_name = @"name";

@implementation HVItemType

@synthesize typeID = m_typeID;
@synthesize name = m_name;

-(id) initWithTypeID:(NSString *)typeID
{
    HVCHECK_STRING(typeID);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.typeID = typeID;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_typeID release];
    [m_name release];
    
    [super dealloc];
}

-(BOOL)isType:(NSString *)typeID
{
    return [m_typeID isEqualToStringCaseInsensitive:typeID];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_typeID, HVClientError_InvalidItemType);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_TEXT(m_typeID);
}

-(void) deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TEXT(m_typeID);
    reader.context = self;
}

@end
