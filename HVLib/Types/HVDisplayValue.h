//
//  HVDisplayValue.h
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
#import "HVType.h"

@interface HVDisplayValue : HVType
{
@private
    double m_value;
    NSString* m_text;
    NSString* m_units;
    NSString* m_unitsCode;
}
@property (readwrite, nonatomic) double value;
@property (readwrite, nonatomic, retain) NSString* text;
@property (readwrite, nonatomic, retain) NSString* units;
@property (readwrite, nonatomic, retain) NSString* unitsCode;

-(id) initWithValue:(double) doubleValue andUnits:(NSString *) unitValue;

@end
