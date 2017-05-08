//
//  MHVCholesterol.h
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
#import "MHVTypes.h"

double const c_cholesterolMolarMass;
double const c_triglyceridesMolarMass;

//
// DEPRECATED DEPRECATED DEPRECATED
//
// APPS SHOULD SWITCH TO MHVCholesterolV2, which correctly handles international units
//
// Cholesterol (Lipid) profile
// Measures Cholesterol #s in mg/DL
// Use MHVCholesterolV2, which uses the SI mmolPerl units
//
@interface MHVCholesterol : MHVItemDataTyped
{
@private
    MHVDate* m_date;
    MHVPositiveInt* m_ldl;
    MHVPositiveInt* m_hdl;
    MHVPositiveInt* m_total;
    MHVPositiveInt* m_triglycerides;
}

//-------------------------
//
// Cholesterol Data
//
//-------------------------
//
// (Required) When the measurement was taken
//
@property (readwrite, nonatomic, strong) MHVDate* when;
//
// (Optional) LDL value in mg/DL
// 
@property (readwrite, nonatomic, strong) MHVPositiveInt* ldl;
//
// (Optional) HDL value in mg/DL
//
@property (readwrite, nonatomic, strong) MHVPositiveInt* hdl;
//
// (Optional) Total cholesterol in mg/DL
//
@property (readwrite, nonatomic, strong) MHVPositiveInt* total;
//
// (Optional) Triglycerides in mg/DL
//
@property (readwrite, nonatomic, strong) MHVPositiveInt* triglycerides;
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

+(MHVItem *) newItem;

@end
