//
//  Weight.h
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

@interface HVWeight : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVWeightMeasurement* m_value;
}

@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* value;
@property (readwrite, nonatomic) double inPounds;
@property (readwrite, nonatomic) double inKg;

-(id) initWithKg:(double) kg andDate:(NSDate*) date;
-(id) initWithPounds:(double) pounds andDate:(NSDate *) date;

//
// Returns weight value in KG
//
-(NSString *) toString;

-(NSString *) stringInPounds;
-(NSString *) stringInKg;
//
// These methods expect a format string with a %f in it, surrounded with other decorative text of your choice
//
-(NSString *) stringInPoundsWithFormat:(NSString *) format;
-(NSString *) stringInKgWithFormat:(NSString *) format;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
