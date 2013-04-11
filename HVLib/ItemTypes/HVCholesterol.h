//
//  HVCholesterol.h
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"

double const c_cholesterolMolarMass;
double const c_triglyceridesMolarMass;

//
// DEPRECATED DEPRECATED DEPRECATED
//
// APPS SHOULD SWITCH TO HVCholesterolV2, which correctly handles international units
//
// Cholesterol (Lipid) profile
// Measures Cholesterol #s in mg/DL
// Use HVCholesterolV2, which uses the SI mmolPerl units
//
@interface HVCholesterol : HVItemDataTyped
{
@private
    HVDate* m_date;
    HVPositiveInt* m_ldl;
    HVPositiveInt* m_hdl;
    HVPositiveInt* m_total;
    HVPositiveInt* m_triglycerides;
}

//-------------------------
//
// Cholesterol Data
//
//-------------------------
//
// (Required) When the measurement was taken
//
@property (readwrite, nonatomic, retain) HVDate* when;
//
// (Optional) LDL value in mg/DL
// 
@property (readwrite, nonatomic, retain) HVPositiveInt* ldl;
//
// (Optional) HDL value in mg/DL
//
@property (readwrite, nonatomic, retain) HVPositiveInt* hdl;
//
// (Optional) Total cholesterol in mg/DL
//
@property (readwrite, nonatomic, retain) HVPositiveInt* total;
//
// (Optional) Triglycerides in mg/DL
//
@property (readwrite, nonatomic, retain) HVPositiveInt* triglycerides;
//
// Convenience properties
//
@property (readwrite, nonatomic) int ldlValue;
@property (readwrite, nonatomic) int hdlValue;
@property (readwrite, nonatomic) int totalValue;
@property (readwrite, nonatomic) int triglyceridesValue;
@property (readwrite, nonatomic) double ldlValueMmolPerLiter;
@property (readwrite, nonatomic) double hdlValueMmolPerLiter;
@property (readwrite, nonatomic) double totalValueMmolPerLiter;
@property (readwrite, nonatomic) double triglyceridesValueMmolPerLiter;

//-------------------------
//
// Initializers
//
//-------------------------
//
// Creates a string for ldl/hdl
//
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
