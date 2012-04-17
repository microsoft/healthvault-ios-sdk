//
//  HVWeightMeasurement.m
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
#import "HVWeightMeasurement.h"

static double const c_PoundsPerKg = 2.20462262185;
static double const c_KgPerPound = 0.45359237;

static NSString* const c_KgUnits = @"kilograms";
static NSString* const c_PoundUnits = @"pounds";

static NSString* const c_element_kg = @"kg";
static NSString* const c_element_display = @"display";

@implementation HVWeightMeasurement

@synthesize value = m_kg;
@synthesize display = m_display;

-(double) kg
{
    return (m_kg) ? m_kg.value : NAN;
}

-(void) setKg:(double)valueInKg
{
    HVENSURE(m_kg, HVPositiveDouble);
    m_kg.value = valueInKg;
    
    [self updateDisplayValue:[HVWeightMeasurement roundKg:valueInKg] andUnits:c_KgUnits];
}

-(double) pounds
{
    return [HVWeightMeasurement kgToPounds:self.kg];
}

-(void) setPounds:(double)valueInPounds
{
    self.kg = [HVWeightMeasurement poundsToKg:valueInPounds];
    [self updateDisplayValue:[HVWeightMeasurement roundPounds:valueInPounds] andUnits:c_PoundUnits];
    
}

-(id) initWithKg:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.kg = value;
    HVCHECK_NOTNULL(m_display);

    return self;
LError:
    HVALLOC_FAIL;
}

-(id) initwithPounds:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.pounds = value;
    HVCHECK_NOTNULL(m_display);
    
    return self;
LError:
    HVALLOC_FAIL;    
}

-(void) dealloc
{
    [m_kg release];
    [m_display release];
    
    [super dealloc];
}

-(BOOL) updateDisplayValue:(double)displayValue andUnits:(NSString *)unitValue
{
    HVDisplayValue *newValue = [[HVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    HVCHECK_NOTNULL(newValue);
    
    HVASSIGN(m_display, newValue);
    
    return TRUE;

LError:
    return FALSE;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.2f kg"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, self.kg];
}

-(NSString *)stringInPounds:(NSString *)format
{
    return [NSString stringWithFormat:format, self.pounds];
}

-(NSString *)stringInOunces:(NSString *)format
{
    return [NSString stringWithFormat:format, self.pounds * 16];    
}

-(NSString *)stringInGrams:(NSString *)format
{
    return [NSString stringWithFormat:format, self.kg * 1000];
}

-(NSString *)stringInKg:(NSString *)format
{
    return [NSString stringWithFormat:format, self.kg];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_kg, HVClientError_InvalidWeightMeasurement);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_kg, c_element_kg);
    HVSERIALIZE(m_display, c_element_display);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_kg, c_element_kg, HVPositiveDouble);
    HVDESERIALIZE(m_display, c_element_display, HVDisplayValue);
}

+(double) kgToPounds:(double)kg
{
    return kg * c_PoundsPerKg;
}

+(double) poundsToKg:(double)pounds
{
    return pounds * c_KgPerPound;
}

+(double) roundKg:(double)kg
{
    return (round(kg * 1000) )/ 1000;  // round to third place (grams)    
}

+(double) roundPounds:(double)pounds
{
    return (round(pounds * 100) )/ 100;  // round to second place (ounces)
}
@end

