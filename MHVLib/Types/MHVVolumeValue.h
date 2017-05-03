//
//  MHVVolumeValue.h
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
//
#import <Foundation/Foundation.h>
#import "MHVType.h"
#import "MHVPositiveDouble.h"
#import "MHVDisplayValue.h"

@interface MHVVolumeValue : MHVType
{
@private
    MHVPositiveDouble* m_liters;
    MHVDisplayValue* m_display;
}

-(id) initWithLiters:(double) value;

//
// Required
//
@property (readwrite, nonatomic, strong) MHVPositiveDouble* liters;
//
// Optional
//
@property (readwrite, nonatomic, strong) MHVDisplayValue* displayValue;

@property (readwrite, nonatomic) double litersValue;

-(NSString *) toString;
-(NSString *)toStringWithFormat:(NSString *)format;

// Liters
+(NSString *) volumeUnits;

@end
