//
//  MHVApproxDateTime.m
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
#import "MHVApproxDateTime.h"

static NSString* const c_element_descriptive = @"descriptive";
static NSString* const c_element_structured = @"structured";

@implementation MHVApproxDateTime

@synthesize descriptive = m_descriptive;
@synthesize dateTime = m_dateTime;

-(void)setDescriptive:(NSString *)descriptive
{
    if (![NSString isNilOrEmpty:descriptive])
    {
        m_dateTime = nil;    
    }
    m_descriptive = descriptive;
}

-(void)setDateTime:(MHVDateTime *)dateTime
{
    if (dateTime)
    {
        m_descriptive = nil;
    }
    m_dateTime = dateTime;
}

-(BOOL)isStructured
{
    return (m_dateTime != nil);
}

-(id)initWithDescription:(NSString *)descr
{
    MHVCHECK_NOTNULL(descr);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.descriptive = descr;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithDate:(NSDate *)date
{
    MHVDateTime* dateTime = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(dateTime);
    
    self = [self initWithDateTime:dateTime];
    
    return self;

LError:
    MHVALLOC_FAIL;
}

-(id)initWithDateTime:(MHVDateTime *)dateTime
{
    MHVCHECK_NOTNULL(dateTime);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.dateTime = dateTime;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initNow
{
    return [self initWithDate:[NSDate date]];
}


+(MHVApproxDateTime *)fromDate:(NSDate *)date
{
    return [[MHVApproxDateTime alloc] initWithDate:date];
}

+(MHVApproxDateTime *)fromDescription:(NSString *)descr
{
    return [[MHVApproxDateTime alloc] initWithDescription:descr];
}

+(MHVApproxDateTime *)now
{
    return [[MHVApproxDateTime alloc] initNow];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    if (m_dateTime)
    {
        return [m_dateTime toString];
    }
    
    return (m_descriptive) ? m_descriptive : c_emptyString;
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (m_dateTime)
    {
        return [m_dateTime toStringWithFormat:format];
    }
    
    return (m_descriptive) ? m_descriptive : c_emptyString;
}

-(NSDate *)toDate
{
    if (m_dateTime)
    {
        return [m_dateTime toDate];
    }
    
    return nil;
}

-(NSDate *)toDateForCalendar:(NSCalendar *)calendar
{
    if (m_dateTime)
    {
        return [m_dateTime toDateForCalendar:calendar];
    }
    
    return nil;    
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    //
    // The data type is a choice. You can do one or the other
    //
    MHVVALIDATE_TRUE((m_dateTime || m_descriptive), MHVClientError_InvalidApproxDateTime);
    MHVVALIDATE_TRUE((!(m_dateTime && m_descriptive)), MHVClientError_InvalidApproxDateTime);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_descriptive value:m_descriptive];
    [writer writeElement:c_element_structured content:m_dateTime];
}

-(void)deserialize:(XReader *)reader
{
    m_descriptive = [reader readStringElement:c_element_descriptive];
    m_dateTime = [reader readElement:c_element_structured asClass:[MHVDateTime class]];
}

@end
