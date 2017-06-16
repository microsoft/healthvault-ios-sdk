//
// MHVCore.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVCore.h"
#import "MHVValidator.h"

NSRange MHVMakeRange(NSUInteger i)
{
    return NSMakeRange(i, 1);
}

NSRange MHVEmptyRange(void)
{
    return NSMakeRange(0, 0);
}

double roundToPrecision(double value, NSInteger precision)
{
    double places;

    // Optimize the common case
    switch (precision)
    {
        case 0:
            places = 1;
            break;

        case 1:
            places = 10;
            break;

        case 2:
            places = 100;
            break;

        case 3:
            places = 1000;
            break;

        default:
            places = pow(10, precision);
            break;
    }
    return round(value * places) / places;
}

double mgDLToMmolPerL(double mgDLValue, double molarWeight)
{
    //
    // DL = 0.1 Liters
    // (10 * mgDL)/1000 = g/L
    // Molar weight = grams/mole
    //
    // ((10 * mgDL)/1000 / molarWeight) * 1000)

    return (10 * mgDLValue) / molarWeight;
}

double mmolPerLToMgDL(double mmolPerL, double molarWeight)
{
    return (mmolPerL * molarWeight) / 10;
}

@implementation NSObject (MHVExtensions)

- (void)log
{
    @try
    {
        MHVLogEvent([self descriptionForLog]);
    }
    @catch (id ex)
    {
    }
}

- (NSString *)descriptionForLog
{
    if ([self respondsToSelector:@selector(detailedDescription)])
    {
        return [self performSelector:@selector(detailedDescription)];
    }
    else if ([self respondsToSelector:@selector(description)])
    {
        return [self description];
    }
    else
    {
        return NSStringFromClass([self class]);
    }
}

@end

