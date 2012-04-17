//
//  HVPendingItem.m
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
#import "HVPendingItem.h"

static NSString* const c_element_id = @"thing-id";
static NSString* const c_element_type = @"type-id";
static NSString* const c_element_edate = @"eff-date";

@implementation HVPendingItem

@synthesize key = m_id;
@synthesize type = m_type;
@synthesize effectiveDate = m_eDate;

-(void) dealloc
{
    [m_id release];
    [m_type release];
    [m_eDate release];
    
    [super dealloc];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_id, HVClientError_InvalidPendingItem);
    HVVALIDATE_OPTIONAL(m_type);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_id, c_element_id);
    HVSERIALIZE(m_type, c_element_type);
    HVSERIALIZE_DATE(m_eDate, c_element_edate);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_id, c_element_id, HVItemKey);
    HVDESERIALIZE(m_type, c_element_type, HVItemType);
    HVDESERIALIZE_DATE(m_eDate, c_element_edate);
}

@end

@implementation HVPendingItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVPendingItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end

