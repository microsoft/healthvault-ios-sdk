//
//  HVVitalSignResult.h
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
#import "HVBaseTypes.h"
#import "HVType.h"
#import "HVCodableValue.h"

@interface HVVitalSignResult : HVType
{
@private
    HVCodableValue* m_title;
    HVDouble* m_value;
    HVCodableValue* m_unit;
    HVDouble* m_referenceMin;
    HVDouble* m_referenceMax;
    NSString* m_textValue;
    HVCodableValue* m_flag;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
// Vocabulary: vital-statistics
//
@property (readwrite, nonatomic, strong) HVCodableValue* title;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVDouble* value;
//
// (Optional)
// Vocabulary: lab-results-units
@property (readwrite, nonatomic, strong) HVCodableValue* unit;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVDouble* referenceMin;
// 
// (Optional)
//
@property (readwrite, nonatomic, strong) HVDouble* referenceMax;
@property (readwrite, nonatomic, strong) NSString* textValue;
@property (readwrite, nonatomic, strong) HVCodableValue* flag;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithTitle:(HVCodableValue *) title value:(double)value andUnit:(NSString *) unit;
-(id) initWithTemperature:(double) value inCelsius:(BOOL) celsius;

//-------------------------
//
// Text
//
//-------------------------

// 
// Format template => %@ %f %@
//
-(NSString *) toString;

@end


@interface HVVitalSignResultCollection : HVCollection 

-(HVVitalSignResult *) itemAtIndex:(NSUInteger) index;

@end
