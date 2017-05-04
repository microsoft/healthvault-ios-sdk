//
//  MHVItemFilter.m
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
#import "MHVItemFilter.h"
#import "MHVItemDataTyped.h"

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

@implementation MHVTypeFilter

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

-(void) serialize:(XWriter *)writer
{
    if (m_state != MHVItemStateNone)
    {
        [writer writeElement:c_element_state value:MHVItemStateToString(m_state)];
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
    NSString* state = [reader readStringElement:c_element_state];
    if (state)
    {
        m_state = MHVItemStateFromString(state);
    }

    m_eDateMin = [reader readDateElement:c_element_edateMin];
    m_eDateMax = [reader readDateElement:c_element_edateMax];
    m_cAppID = [reader readStringElement:c_element_cappID];
    m_cPersonID = [reader readStringElement:c_element_cpersonID];
    m_uAppID = [reader readStringElement:c_element_uappID];
    m_uPersonID = [reader readStringElement:c_element_upersonID];
    m_cDateMin = [reader readDateElement:c_element_cdateMin];
    m_cDateMax = [reader readDateElement:c_element_cdateMax];
    m_uDateMin = [reader readDateElement:c_element_udateMin];
    m_udateMax = [reader readDateElement:c_element_udateMax];
    m_xpath = [reader readStringElement:c_element_xpath];
}

@end

@implementation MHVItemFilter

-(MHVStringCollection *)typeIDs
{
    MHVENSURE(m_typeIDs, MHVStringCollection);
    return m_typeIDs;
}

-(void)setTypeIDs:(MHVStringCollection *)typeIDs
{
    m_typeIDs = typeIDs;
}

-(id) init
{
    return [self initWithTypeID:nil];
}

-(id) initWithTypeID:(NSString *)typeID
{
    self = [super init];
    MHVCHECK_SELF;
    
    if (typeID)
    {
        [self.typeIDs addObject:typeID];
        MHVCHECK_NOTNULL(m_typeIDs);
    }
    
    m_state = MHVItemStateActive;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithTypeClass:(Class)typeClass
{
    NSString* typeID = [[MHVTypeSystem current] getTypeIDForClassName:NSStringFromClass(typeClass)];
    MHVCHECK_NOTNULL(typeID);
    
    return [self initWithTypeID:typeID];
    
LError:
    MHVALLOC_FAIL;
}


-(void) serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_typeID elements:m_typeIDs];
    [super serialize:writer];
}

-(void) deserialize:(XReader *)reader
{
    m_typeIDs = [reader readStringElementArray:c_element_typeID];
    [super deserialize:reader];
}

@end

@implementation MHVItemFilterCollection

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVItemFilter class];
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void)addItem:(MHVItemFilter *)filter
{
    [super addObject:filter];
}

-(MHVItemFilter *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
