//
//  MHVLengthMeasurement.m
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
#import "MHVLengthMeasurement.h"

static const xmlChar* x_element_meters = XMLSTRINGCONST("m");
static const xmlChar* x_element_display = XMLSTRINGCONST("display");

@implementation MHVLengthMeasurement

@synthesize value = m_meters;
@synthesize display = m_display;

-(double)inMeters
{
    return (m_meters) ? m_meters.value : NAN;
}

-(void)setInMeters:(double)meters
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = meters;
    [self updateDisplayValue:meters units:@"meters" andUnitsCode:@"m"];
}

-(double)inCentimeters
{
    return self.inMeters * 100;
}

-(void)setInCentimeters:(double)inCentimeters
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = inCentimeters / 100;
    [self updateDisplayValue:inCentimeters units:@"centimeters" andUnitsCode:@"cm"];
}

-(double)inKilometers
{
    return self.inMeters / 1000;
}

-(void)setInKilometers:(double)inKilometers
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = inKilometers * 1000;
    [self updateDisplayValue:inKilometers units:@"kilometers" andUnitsCode:@"km"];
}

-(double) inInches
{
    return (m_meters) ? [MHVLengthMeasurement metersToInches:m_meters.value] : NAN;
}

-(void)setInInches:(double)inches
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = [MHVLengthMeasurement inchesToMeters:inches];
    [self updateDisplayValue:inches units:@"inches" andUnitsCode:@"in"];
}

-(double)inFeet
{
    return self.inInches / 12;
}

-(void)setInFeet:(double)inFeet
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = [MHVLengthMeasurement inchesToMeters:inFeet * 12];
    [self updateDisplayValue:inFeet units:@"feet" andUnitsCode:@"ft"];    
}

-(double)inMiles
{
    return self.inFeet / 5280;
}

-(void)setInMiles:(double)inMiles
{
    MHVENSURE(m_meters, MHVPositiveDouble);
    m_meters.value = [MHVLengthMeasurement inchesToMeters:inMiles * 5280 * 12];
    [self updateDisplayValue:inMiles units:@"miles" andUnitsCode:@"mi"];        
}


-(id)initWithInches:(double)inches
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.inInches = inches;
    MHVCHECK_NOTNULL(m_meters);
    MHVCHECK_NOTNULL(m_display);
    
    return self;
LError:
    MHVALLOC_FAIL;    
}

-(id)initWithMeters:(double)meters
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.inMeters = meters;
    MHVCHECK_NOTNULL(m_meters);
    MHVCHECK_NOTNULL(m_display);
    
    return self;
LError:
    MHVALLOC_FAIL;
}

-(BOOL) updateDisplayValue:(double)displayValue units:(NSString *)unitValue andUnitsCode:(NSString *)code
{
    MHVDisplayValue *newValue = [[MHVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    MHVCHECK_NOTNULL(newValue);
    if (code)
    {
        newValue.unitsCode = code;
    }

    m_display = newValue;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)toString
{
    return [self stringInMeters:@"%.2f m"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.inMeters];
}

-(NSString *)stringInCentimeters:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.inCentimeters];    
}

-(NSString *)stringInMeters:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.inMeters];
}

-(NSString *)stringInKilometers:(NSString *)format  
{
    return [NSString localizedStringWithFormat:format, self.inKilometers];    
}

-(NSString *) stringInInches:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.inInches];
}

-(NSString *)stringInFeetAndInches:(NSString *)format
{
    long totalInches = (long) round(self.inInches);
    long feet = totalInches / 12;
    long inches = totalInches % 12;
    
    return [NSString localizedStringWithFormat:format, feet, inches];
}

-(NSString *)stringInMiles:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.inMiles];        
}

+(MHVLengthMeasurement *)fromMiles:(double)value
{
    MHVLengthMeasurement* length = [[MHVLengthMeasurement alloc] init];
    length.inMiles = value;
    return length;
}

+(MHVLengthMeasurement *)fromInches:(double)value
{
    MHVLengthMeasurement* length = [[MHVLengthMeasurement alloc] init];
    length.inInches = value;
    return length;    
}

+(MHVLengthMeasurement *)fromKilometers:(double)value
{
    MHVLengthMeasurement* length = [[MHVLengthMeasurement alloc] init];
    length.inKilometers = value;
    return length;    
}

+(MHVLengthMeasurement *)fromMeters:(double)value
{
    MHVLengthMeasurement* length = [[MHVLengthMeasurement alloc] init];
    length.inMeters = value;
    return length;    
}

+(MHVLengthMeasurement *)fromCentimeters:(double)value
{
    MHVLengthMeasurement* length = [[MHVLengthMeasurement alloc] init];
    length.inCentimeters = value;
    return length;    
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_meters, MHVClientError_InvalidLengthMeasurement);
    MHVVALIDATE_OPTIONAL(m_display);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_meters content:m_meters];
    [writer writeElementXmlName:x_element_display content:m_display];
}

-(void) deserialize:(XReader *)reader
{
    m_meters = [reader readElementWithXmlName:x_element_meters asClass:[MHVPositiveDouble class]];
    m_display = [reader readElementWithXmlName:x_element_display asClass:[MHVDisplayValue class]];
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
    return [MHVLengthMeasurement centimetersToInches:meters * 100];
}

+(double)inchesToMeters:(double)inches
{
    return [MHVLengthMeasurement inchesToCentimeters:inches] / 100;
}

@end
