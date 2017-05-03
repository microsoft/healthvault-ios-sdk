//
//  HVCholesterolV2.h
//  HVLib
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
#import "HVTypes.h"
#import "HVCholesterol.h"

@interface HVCholesterolV2 : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVConcentrationValue* m_ldl;
    HVConcentrationValue* m_hdl;
    HVConcentrationValue* m_total;
    HVConcentrationValue* m_triglycerides;
}

//
// (Required) When the measurement was taken
//
@property (readwrite, nonatomic, strong) HVDateTime* when;
//
// (Optional) LDL value in mg/DL
//
@property (readwrite, nonatomic, strong) HVConcentrationValue* ldl;
//
// (Optional) HDL value in mg/DL
//
@property (readwrite, nonatomic, strong) HVConcentrationValue* hdl;
//
// (Optional) Total cholesterol in mg/DL
//
@property (readwrite, nonatomic, strong) HVConcentrationValue* total;
//
// (Optional) Triglycerides in mg/DL
//
@property (readwrite, nonatomic, strong) HVConcentrationValue* triglycerides;
//
// Convenience properties
//
@property (readwrite, nonatomic) double ldlValue;
@property (readwrite, nonatomic) double hdlValue;
@property (readwrite, nonatomic) double totalValue;
@property (readwrite, nonatomic) double triglyceridesValue;
@property (readwrite, nonatomic) double ldlValueMgDL;
@property (readwrite, nonatomic) double hdlValueMgDL;
@property (readwrite, nonatomic) double totalValueMgDL;
@property (readwrite, nonatomic) double triglyceridesValueMgDl;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
