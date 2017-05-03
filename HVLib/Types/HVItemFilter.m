//
//  HVItemFilter.m
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
#import "HVItemFilter.h"
#import "HVItemDataTyped.h"

static NSString* const c_element_typeID = @"type-id";
static NSString* const c_element_state = @"thing-state";
static NSString* const c_element_edateMin = @"eff-date-min";
static NSString* const c_element_edateMax = @"eff-date-max";
static NSString* const c_element_cappID = @"created-app-id";
static NSString* const c_element_cpersonID = @"created-person-id";
static NSString* const c_element_uappID = @"updated-app-id";
static NSString* const c_element_upersonID = @"updated-person-id";
static NSString* const c_element_cdateMin = @"created-date-min";
static NSString* const c_element_cdateMax = @"created-date-max";
static NSString* const c_element_udateMin = @"updated-date-min";
static NSString* const c_element_udateMax = @"updated-date-max";
static NSString* const c_element_xpath = @"xpath";

@implementation HVTypeFilter

@synthesize state = m_state;
@synthesize effectiveDateMin = m_eDateMin;
@synthesize effectiveDateMax = m_eDateMax;
@synthesize createdByAppID = m_cAppID;
@synthesize createdByPersonID = m_cPersonID;
@synthesize updatedByAppID = m_uAppID;
@synthesize updatedByPersonID = m_uPersonID;
@synthesize createDateMin = m_cDateMin;
@synthesize createDateMax = m_cDateMax;
@synthesize updateDateMin = m_uDateMin;
@synthesize updateDateMax = m_udateMax;
@synthesize xpath = m_xpath;

-(void) dealloc
{
    [m_eDateMin release];
    [m_eDateMax release];
    [m_cAppID release];
    [m_cPersonID release];
    [m_uAppID release];
    [m_uPersonID release];
    [m_cDateMin release];
    [m_cDateMax release];
    [m_uDateMin release];
    [m_udateMax release];
    [m_xpath release];
    
    [super dealloc];
    
}
-(void) serialize:(XWriter *)writer
{
    if (m_state != HVItemStateNone)
    {
        [writer writeElement:c_element_state value:HVItemStateToString(m_state)];
    }
    
    [writer writeElement:c_element_edateMin dateValue:m_eDateMin];
    [writer writeElement:c_element_edateMax dateValue:m_eDateMax];
    [writer writeElement:c_element_cappID value:m_cAppID];
    [writer writeElement:c_element_cpersonID value:m_cPersonID];
    [writer writeElement:c_element_uappID value:m_uAppID];
    [writer writeElement:c_element_upersonID value:m_uPersonID];
    [writer writeElement:c_element_cdateMin dateValue:m_cDateMin];
    [writer writeElement:c_element_cdateMax dateValue:m_cDateMax];
    [writer writeElement:c_element_udateMin dateValue:m_uDateMin];
    [writer writeElement:c_element_udateMax dateValue:m_udateMax];
    [writer writeElement:c_element_xpath value:m_xpath];
}

-(void) deserialize:(XReader *)reader
{
    NSString* state = [[reader readStringElement:c_element_state] retain];
    if (state)
    {
        m_state = HVItemStateFromString(state);
    }

    m_eDateMin = [[reader readDateElement:c_element_edateMin] retain];
    m_eDateMax = [[reader readDateElement:c_element_edateMax] retain];
    m_cAppID = [[reader readStringElement:c_element_cappID] retain];
    m_cPersonID = [[reader readStringElement:c_element_cpersonID] retain];
    m_uAppID = [[reader readStringElement:c_element_uappID] retain];
    m_uPersonID = [[reader readStringElement:c_element_upersonID] retain];
    m_cDateMin = [[reader readDateElement:c_element_cdateMin] retain];
    m_cDateMax = [[reader readDateElement:c_element_cdateMax] retain];
    m_uDateMin = [[reader readDateElement:c_element_udateMin] retain];
    m_udateMax = [[reader readDateElement:c_element_udateMax] retain];
    m_xpath = [[reader readStringElement:c_element_xpath] retain];
}

@end

@implementation HVItemFilter

-(HVStringCollection *)typeIDs
{
    HVENSURE(m_typeIDs, HVStringCollection);
    return m_typeIDs;
}

-(void)setTypeIDs:(HVStringCollection *)typeIDs
{
    m_typeIDs = [typeIDs retain];
}

-(id) init
{
    return [self initWithTypeID:nil];
}

-(id) initWithTypeID:(NSString *)typeID
{
    self = [super init];
    HVCHECK_SELF;
    
    if (typeID)
    {
        [self.typeIDs addObject:typeID];
        HVCHECK_NOTNULL(m_typeIDs);
    }
    
    m_state = HVItemStateActive;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithTypeClass:(Class)typeClass
{
    NSString* typeID = [[HVTypeSystem current] getTypeIDForClassName:NSStringFromClass(typeClass)];
    HVCHECK_NOTNULL(typeID);
    
    return [self initWithTypeID:typeID];
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_typeIDs release];    
    [super dealloc];
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_typeID elements:m_typeIDs];
    [super serialize:writer];
}

-(void) deserialize:(XReader *)reader
{
    m_typeIDs = [[reader readStringElementArray:c_element_typeID] retain];
    [super deserialize:reader];
}

@end

@implementation HVItemFilterCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVItemFilter class];
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(HVItemFilter *)filter
{
    [super addObject:filter];
}

-(HVItemFilter *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
