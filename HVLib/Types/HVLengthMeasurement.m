//
//  HVLengthMeasurement.m
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
#import "HVLengthMeasurement.h"

static NSString* const c_element_meters = @"m";
static NSString* const c_element_display = @"display";

@implementation HVLengthMeasurement

@synthesize value = m_meters;
@synthesize display = m_display;

-(double)inMeters
{
    return (m_meters) ? m_meters.value : NAN;
}

-(void)setInMeters:(double)meters
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = meters;
    [self updateDisplayValue:meters units:@"meters" andUnitsCode:@"m"];
}

-(double)inCentimeters
{
    return self.inMeters * 100;
}

-(void)setInCentimeters:(double)inCentimeters
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = inCentimeters / 100;
    [self updateDisplayValue:inCentimeters units:@"centimeters" andUnitsCode:@"cm"];
}

-(double)inKilometers
{
    return self.inMeters / 1000;
}

-(void)setInKilometers:(double)inKilometers
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = inKilometers * 1000;
    [self updateDisplayValue:inKilometers units:@"kilometers" andUnitsCode:@"km"];
}

-(double) inInches
{
    return (m_meters) ? [HVLengthMeasurement metersToInches:m_meters.value] : NAN;
}

-(void)setInInches:(double)inches
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = [HVLengthMeasurement inchesToMeters:inches];
    [self updateDisplayValue:inches units:@"inches" andUnitsCode:@"in"];
}

-(double)inFeet
{
    return self.inInches / 12;
}

-(void)setInFeet:(double)inFeet
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = [HVLengthMeasurement inchesToMeters:inFeet * 12];
    [self updateDisplayValue:inFeet units:@"feet" andUnitsCode:@"ft"];    
}

-(double)inMiles
{
    return self.inFeet / 5280;
}

-(void)setInMiles:(double)inMiles
{
    HVENSURE(m_meters, HVPositiveDouble);
    m_meters.value = [HVLengthMeasurement inchesToMeters:inMiles * 5280 * 12];
    [self updateDisplayValue:inMiles units:@"miles" andUnitsCode:@"mi"];        
}

-(void)dealloc
{
    [m_meters release];
    [m_display release];
    [super dealloc];
}

-(id)initWithInches:(double)inches
{
    self = [super init];
    HVCHECK_SELF;
    
    self.inInches = inches;
    HVCHECK_NOTNULL(m_meters);
    HVCHECK_NOTNULL(m_display);
    
    return self;
LError:
    HVALLOC_FAIL;    
}

-(id)initWithMeters:(double)meters
{
    self = [super init];
    HVCHECK_SELF;
    
    self.inMeters = meters;
    HVCHECK_NOTNULL(m_meters);
    HVCHECK_NOTNULL(m_display);
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(BOOL) updateDisplayValue:(double)displayValue units:(NSString *)unitValue andUnitsCode:(NSString *)code
{
    HVDisplayValue *newValue = [[HVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    HVCHECK_NOTNULL(newValue);
    
    HVASSIGN(m_display, newValue);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)toString
{
    return [self stringInMeters:@"%d m"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, self.inMeters];
}

-(NSString *)stringInMeters:(NSString *)format
{
    return [NSString stringWithFormat:format, self.inMeters];
}

-(NSString *) stringInInches:(NSString *)format
{
    return [NSString stringWithFormat:format, self.inInches];
}

-(NSString *)stringInFeetAndInches:(NSString *)format
{
    long totalInches = (long) round(self.inInches);
    long feet = totalInches / 12;
    long inches = totalInches % 12;
    
    return [NSString stringWithFormat:format, feet, inches];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_meters, HVClientError_InvalidLengthMeasurement);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_meters, c_element_meters);
    HVSERIALIZE(m_display, c_element_display);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_meters, c_element_meters, HVPositiveDouble);
    HVDESERIALIZE(m_display, c_element_display, HVDisplayValue);
}

+(double)centimetersToInches:(double)cm
{
    return cm * 0.3937;
}

+(double)inchesToCentimeters:(double)cm
{
    return cm * 2.54;
}

+(double)metersToInches:(double)meters
{
    return [HVLengthMeasurement centimetersToInches:meters * 100];
}

+(double)inchesToMeters:(double)inches
{
    return [HVLengthMeasurement inchesToCentimeters:inches] / 100;
}

@end
