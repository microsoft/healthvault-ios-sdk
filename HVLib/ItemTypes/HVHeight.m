//
//  HVHeight.m
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
#import "HVHeight.h"

static NSString* const c_typeid = @"40750a6a-89b2-455c-bd8d-b420a4cb500b";
static NSString* const c_typename = @"height";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");

@implementation HVHeight

@synthesize when = m_when;
@synthesize value = m_height;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(double)inMeters
{
    return (m_height) ? m_height.inMeters : NAN;
}

-(void)setInMeters:(double)inMeters 
{
    HVENSURE(m_height, HVLengthMeasurement);
    m_height.inMeters = inMeters;        
}

-(double)inInches
{
    return (m_height) ? m_height.inInches : NAN;
}

-(void)setInInches:(double)inInches
{
    HVENSURE(m_height, HVLengthMeasurement);
    m_height.inInches = inInches;
}

-(void)dealloc
{
    [m_when release];
    [m_height release];
    [super dealloc];
}

-(id)initWithMeters:(double)meters andDate:(NSDate *)date
{
    self = [super init];
    HVCHECK_SELF;
    
    self.inMeters = meters;
    HVCHECK_NOTNULL(m_height);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithInches:(double)inches andDate:(NSDate *)date
{
    self = [super init];
    HVCHECK_SELF;
    
    self.inInches = inches;
    HVCHECK_NOTNULL(m_height);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSString *)stringInMeters:(NSString *)format
{
   return (m_height) ? [m_height stringInMeters:format] : c_emptyString; 
}

-(NSString *)stringInInches:(NSString *)format
{
    return (m_height) ? [m_height stringInInches:format] : c_emptyString;
}

-(NSString *)stringInFeetAndInches:(NSString *)format
{
    return (m_height) ? [m_height stringInFeetAndInches:format] : c_emptyString;
}

-(NSString *)toString
{
    return (m_height) ? [m_height toString] : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidWeight);
    HVVALIDATE(m_height, HVClientError_InvalidWeight);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;   
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_when, x_element_when);
    HVSERIALIZE_X(m_height, x_element_value);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_when, x_element_when, HVDateTime);
    HVDESERIALIZE_X(m_height, x_element_value, HVLengthMeasurement);
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVHeight typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Height", @"Height Type Name");
}

@end
