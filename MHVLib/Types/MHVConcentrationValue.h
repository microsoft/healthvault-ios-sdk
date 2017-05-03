//
//  MHVConcentrationValue.h
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

#import <Foundation/Foundation.h>
#import "MHVType.h"
#import "MHVNonNegativeDouble.h"
#import "MHVDisplayValue.h"

NSString* const c_element_mmolPL;
NSString* const c_element_display;

NSString* const c_mmolPlUnits;
NSString* const c_mmolUnitsCode;
NSString* const c_mgDLUnits;
NSString* const c_mgDLUnitsCode;

const xmlChar* x_element_mmolPL;
const xmlChar* x_element_display;

//
// Concentration values, stored in mmol/Liter
// Most commonly used to store Cholesterol Measurements
//
@interface MHVConcentrationValue : MHVType
{
@private
    MHVNonNegativeDouble* m_mmolPerl;
    MHVDisplayValue* m_display;
}

//
// Required
//
@property (readwrite, nonatomic, strong) MHVNonNegativeDouble* value;
//
// Optional
//
@property (readwrite, nonatomic, strong) MHVDisplayValue *display;

@property (readwrite, nonatomic) double mmolPerLiter;

-(id) initWithMmolPerLiter:(double) value;
-(id) initWithMgPerDL:(double) value gramsPerMole:(double) gramsPerMole;

-(double) mgPerDL:(double) gramsPerMole;
-(void) setMgPerDL:(double) value gramsPerMole:(double) gramsPerMole;

-(BOOL) updateDisplayValue:(double) displayValue units:(NSString *) unitValue andUnitsCode:(NSString *)code;

-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

@end
