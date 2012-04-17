//
//  HVDate.m
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
#import "HVDate.h"

static NSString* const c_element_year  = @"y";
static NSString* const c_element_month = @"m";
static NSString* const c_element_day   = @"d";

@implementation HVDate

-(int) year
{
    return (m_year) ? m_year.value : -1;
}

-(void) setYear:(int)year
{
    if (year >= 0)
    {
        HVENSURE(m_year, HVYear);
        m_year.value = year;
    }
    else
    {
        HVCLEAR(m_year);
    }
}

-(int) month
{
    return (m_month) ? m_month.value : -1;
}

-(void) setMonth:(int) month
{
    if (month >= 0)
    {
        HVENSURE(m_month, HVMonth);
        m_month.value = month;
    }
    else
    {
        HVCLEAR(m_month);
    }
}

-(int) day
{
    return (m_day) ? m_day.value : -1;
}

-(void) setDay:(int)day
{
    if (day >= 0)
    {
        HVENSURE(m_day, HVDay);
        m_day.value = day;
    }
    else
    {
        HVCLEAR(m_day);
    }
}

-(id) initWithDate:(NSDate *) date
{
    HVCHECK_NOTNULL(date);
    
    [self initWithComponents:[NSCalendar componentsFromDate:date]]; 
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    return [self initWithYear:[components year] month:[components month] day:[components day]];
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithYear:(int) yearValue month:(int) monthValue day:(int) dayValue
{
    self = [super init];
    HVCHECK_SELF;
      
    m_year = [[HVYear alloc] initWith:yearValue];
    m_month = [[HVMonth alloc] initWith:monthValue];
    m_day = [[HVDay alloc] initWith:dayValue];
  
    HVCHECK_TRUE(m_year && m_month && m_day);
  
    return self;

LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_year release];
    [m_month release];
    [m_day release];
    [super dealloc];
}

-(NSDateComponents *) toComponents
{
    NSDateComponents *components = [[NSCalendar newComponents] autorelease];
    HVCHECK_NOTNULL(components);
    
    HVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
    
LError:
    [components release];
    return nil;
}

-(BOOL) getComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    if (m_year)
    {
        [components setYear:self.year];
    }
    if (m_month)
    {
        [components setMonth:self.month];
    }
    if (m_day)
    {
        [components setDay:self.day];
    }
     
    return TRUE;

LError:
    return FALSE;
}

-(NSDate *) toDate
{
    NSDateComponents *components = [NSCalendar newComponents];
    HVCHECK_NOTNULL(components);
    
    HVCHECK_SUCCESS([self getComponents:components]);  
    
    NSDate *date = [components date];
    [components release]; 
    return date;
    
LError:
    [components release];
    return nil;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"MM/dd/YY"];   
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDate* date = [self toDate];
    return [date toStringWithFormat:format];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_year, HVClientError_InvalidDate);
    HVVALIDATE(m_month, HVClientError_InvalidDate);
    HVVALIDATE(m_day, HVClientError_InvalidDate);
      
    HVVALIDATE_SUCCESS;

LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *) writer
{   
    HVSERIALIZE(m_year, c_element_year);
    HVSERIALIZE(m_month, c_element_month);
    HVSERIALIZE(m_day, c_element_day);
}

-(void) deserialize:(XReader *)reader
{    
    HVDESERIALIZE(m_year, c_element_year, HVYear); 
    HVDESERIALIZE(m_month, c_element_month, HVMonth); 
    HVDESERIALIZE(m_day, c_element_day, HVDay); 
}

@end

