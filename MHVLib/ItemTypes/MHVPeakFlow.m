//
//  MHVPeakFlow.m
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
//
//

#import "MHVCommon.h"
#import "MHVPeakFlow.h"

static NSString* const c_typeID = @"5d8419af-90f0-4875-a370-0f881c18f6b3";
static NSString* const c_typeName = @"peak-flow";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_pef = XMLSTRINGCONST("pef");
static const xmlChar* x_element_fev1 = XMLSTRINGCONST("fev1");
static const xmlChar* x_element_fev6 = XMLSTRINGCONST("fev6");
static const xmlChar* x_element_flags = XMLSTRINGCONST("measurement-flags");

@implementation MHVPeakFlow

@synthesize when = m_when;
@synthesize peakExpiratoryFlow = m_pef;
@synthesize forcedExpiratoryVolume1 = m_fev1;
@synthesize forcedExpiratoryVolume6 = m_fev6;
@synthesize flags = m_flags;

-(double)pefValue
{
    return (m_pef) ? m_pef.litersPerSecondValue : NAN;
}

-(void)setPefValue:(double)pefValue
{
    if (isnan(pefValue))
    {
        m_pef = nil;
    }
    else
    {
        HVENSURE(m_pef, MHVFlowValue);
        m_pef.litersPerSecondValue = pefValue;
    }
}

-(id)initWithDate:(NSDate *)when
{
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[MHVApproxDateTime alloc] initWithDate:when];
    HVCHECK_NOTNULL(m_when);
    
    return self;
LError:
    HVALLOC_FAIL;
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(NSString *) toString
{
    return [NSString localizedStringWithFormat:@"pef: %@, fev1: %@",
            m_pef ? [m_pef toString] : c_emptyString,
            m_fev1 ? [m_fev1 toString] : c_emptyString
            ];
}

-(NSString *)description
{
    return [self toString];
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidPeakFlow);
    HVVALIDATE_OPTIONAL(m_pef);
    HVVALIDATE_OPTIONAL(m_fev1);
    HVVALIDATE_OPTIONAL(m_fev6);
    HVVALIDATE_OPTIONAL(m_flags);
    
    HVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_pef content:m_pef];
    [writer writeElementXmlName:x_element_fev1 content:m_fev1];
    [writer writeElementXmlName:x_element_fev6 content:m_fev6];
    [writer writeElementXmlName:x_element_flags content:m_flags];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    m_pef = [reader readElementWithXmlName:x_element_pef asClass:[MHVFlowValue class]];
    m_fev1 = [reader readElementWithXmlName:x_element_fev1 asClass:[MHVVolumeValue class]];
    m_fev6 = [reader readElementWithXmlName:x_element_fev6 asClass:[MHVVolumeValue class]];
    m_flags = [reader readElementWithXmlName:x_element_flags asClass:[MHVCodableValue class]];
}

+(NSString *) typeID
{
    return c_typeID;
}

+(NSString *) XRootElement
{
    return c_typeName;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVPeakFlow typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Peak Flow", @"Peak Flow Type Name");
}
@end
