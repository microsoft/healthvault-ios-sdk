//
// NSString+Utils.m
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
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import "MHVValidator.h"

static NSString *kStringTrue = @"true";
static NSString *kStringFalse = @"false";

@implementation NSString (Utils)

- (NSString*)stringByRemovingHTMLTags
{
    NSRange     range;
    
    //Start by making <p> to newlines, so some formatting carries over.
    NSString    *workString = [self copy];
    workString = [workString stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, workString.length)];
    //...Could do the same for <br> types, but I've only seen <p> in the data...
    
    //Strip any other HTML tags.
    while ((range = [workString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        workString = [workString stringByReplacingCharactersInRange:range withString:@""];
    }
    
    //Cleanup any newlines at the beginning or end.
    return [workString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (NSString*)stringFromNumber:(NSNumber*)number
{
    if (!number)
    {
        number = @(0);
    }
    
    //To get 1,234 instead of 1234  (Or 1.234 in some countries)
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:number];
}

+ (NSNumber *)numberFromString:(NSString *)string
{
    if ([NSString isNilOrEmpty:string])
    {
        return nil;
    }
    
    // Removes commas and other possible charaters added using stringFromNumber:
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [formatter numberFromString:string];
}

+ (NSString*)stringFromInt:(NSInteger)number
{
    return [NSString stringFromNumber:[NSNumber numberWithInteger:number]];
}

+ (NSInteger)intFromString:(NSString *)string
{
    return [NSString numberFromString:string].integerValue;
}

+ (NSString*)stringFromIntSigned:(NSInteger)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    NSString *value = [NSString stringFromNumber:[NSNumber numberWithInteger:number]];
    if (number >= 0 && ![value hasPrefix:formatter.plusSign])
    {
        value = [formatter.plusSign stringByAppendingString:value];
    }
    return value;
}

+ (NSString*)stringByRoundingUpDistance:(double)distance decimals:(NSInteger)decimals
{
    return [self stringFromDouble:distance
                         decimals:decimals
               stripTrailingZeros:NO
                     roundingMode:NSNumberFormatterRoundHalfUp];
}

+ (NSString*)stringFromDouble:(double)number decimals:(NSInteger)decimals
{
    return [NSString stringFromDouble:number decimals:decimals stripTrailingZeros:NO];
}

+ (NSString *)stringFromDouble:(double)number decimals:(NSInteger)decimals stripTrailingZeros:(BOOL)stripTrailingZeros
{
    return [self stringFromDouble:number
                         decimals:decimals
               stripTrailingZeros:stripTrailingZeros
                     roundingMode:NSNumberFormatterRoundFloor];
}

+ (NSString *)stringFromDouble:(double)number
                      decimals:(NSInteger)decimals
            stripTrailingZeros:(BOOL)stripTrailingZeros
                  roundingMode:(NSNumberFormatterRoundingMode)roundingMode
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    
    formatter.roundingMode = roundingMode;
    
    if(stripTrailingZeros)
    {
        NSString *positiveFormat = @"0.";
        for(NSInteger decimalCount = 0; decimalCount < decimals; decimalCount++)
        {
            positiveFormat = [positiveFormat stringByAppendingString:@"#"];
        }
        formatter.positiveFormat = positiveFormat;
    }
    return [formatter stringFromNumber:@(number)];
}


+ (NSString *)roundedDecimalLimitedStringFromDouble:(double)number
                                           decimals:(NSInteger)decimals
                                       roundingMode:(NSNumberFormatterRoundingMode)roundingMode
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.roundingMode = roundingMode;
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    
    return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

+ (NSString*)stringFromDoubleDistance:(double)distance
{
    float decimals = 2;
    if (distance >= 100)
    {
        decimals = 0;
    }
    else if (distance >= 10)
    {
        decimals = 1;
    }
    
    return [NSString stringByRoundingUpDistance:distance decimals:decimals];
}

- (NSUUID*)toBigEndianUUID
{
    NSParameterAssert(self.length == 36);
    NSParameterAssert([self characterAtIndex:8] == '-');
    NSParameterAssert([self characterAtIndex:13] == '-');
    NSParameterAssert([self characterAtIndex:18] == '-');
    NSParameterAssert([self characterAtIndex:23] == '-');
    
    //Android uses big-endian whereas iOS uses little endian.
    //11223344-5566-7788-XXXX-XXXXXXXXXXXX reorders to 44332211-6655-8877-XXXX-XXXXXXXXXXXX
    
    NSString *aa1 = [self substringWithRange:NSMakeRange(0, 2)];
    NSString *bb1 = [self substringWithRange:NSMakeRange(2, 2)];
    NSString *cc1 = [self substringWithRange:NSMakeRange(4, 2)];
    NSString *dd1 = [self substringWithRange:NSMakeRange(6, 2)];
    NSString *aa2 = [self substringWithRange:NSMakeRange(9, 2)];
    NSString *bb2 = [self substringWithRange:NSMakeRange(11, 2)];
    NSString *aa3 = [self substringWithRange:NSMakeRange(14, 2)];
    NSString *bb3 = [self substringWithRange:NSMakeRange(16, 2)];
    
    NSString *uuid = [[NSString stringWithFormat:@"%@%@%@%@-%@%@-%@%@-%@",
                       dd1, cc1, bb1, aa1,
                       bb2, aa2,
                       bb3, aa3, [self substringFromIndex:19]] uppercaseString];
    
    return [[NSUUID alloc] initWithUUIDString:uuid];
}

- (NSString*)substringToIndexUTFSafe:(NSUInteger)to
{
    if (to >= self.length)
    {
        return self;
    }
    else if (to == 0)
    {
        return @"";
    }
    //substringToIndex will split multibyte Unicode characters, crashed other things later because of invalid character sequences.
    return [self substringWithRange:[self rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, to)]];
}

- (NSString*)substringFromIndexUTFSafe:(NSUInteger)from
{
    if (from >= self.length)
    {
        return @"";
    }
    //substringFromIndex will split multibyte Unicode characters, crashed other things later because of invalid character sequences.
    return [self substringWithRange:[self rangeOfComposedCharacterSequencesForRange:NSMakeRange(from, self.length - from)]];
}

- (NSString*)substringToStringWithMaxBytes:(NSUInteger)maxBytes
{
    //Find the number of Unicode characters that fit in a specified number of bytes.
    NSInteger start = MIN(maxBytes, self.length);
    for (NSInteger i = start; i >= 0; i--)
    {
        NSString *substring = [self substringToIndexUTFSafe:i];
        
        if ([substring lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= maxBytes)
        {
            return substring;
        }
    }
    return @"";
}

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    return (string == nil) ||
    ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0);
}

- (NSString*)uppercaseStringLocalized
{
    return [self uppercaseStringWithLocale:[NSLocale currentLocale]];
}


//TODO: Only used by Golf, so move to golf view model or golf class
+ (NSString*)stringFromDoubleDistanceGolf:(double)distance
{
    float decimals = 2;
    if (distance >= 1)
    {
        decimals = 1;
    }
    
    return [NSString stringFromDouble:distance decimals:decimals];
}

- (BOOL)containsSubString:(NSString *)string
{
    //-containsString is iOS8 and up
    NSParameterAssert(string);
    if (!string)
    {
        return NO;
    }
    return ([self rangeOfString:string].location != NSNotFound);
}

- (BOOL)containsSubStringCaseInsensative:(NSString *)string
{
    //-containsString is iOS8 and up
    NSParameterAssert(string);
    if (!string)
    {
        return NO;
    }
    return ([self rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound);
}



- (NSString *)obfuscatedString
{
    if ([NSString isNilOrEmpty:self] || self.length < 2)
    {
        return self;
    }
    
    NSString *obfuscation = [@"" stringByPaddingToLength:self.length - 1 withString: @"*" startingAtIndex:0];
    
    return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1], obfuscation];
}

- (NSString *)substringFromString:(NSString *)startString toString:(NSString *)endString
{
    if (!startString || !endString)
    {
        return nil;
    }
    
    NSRange start = [self rangeOfString:startString];
    
    if (start.location == NSNotFound)
    {
        return nil;
    }
    
    NSInteger location = start.location + start.length;
    
    NSRange end = [[self substringFromIndex:location] rangeOfString:endString];
    
    if (end.location == NSNotFound)
    {
        return nil;
    }
    
    // Use the start location + length and the end LOCATION to determine the range (since end uses substring from index)
    NSRange range = NSMakeRange(location, end.location);
    
    return [self substringWithRange:range];
}

- (NSData *)prettyPrintedJsonData
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    if (data)
    {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([NSJSONSerialization isValidJSONObject:json])
        {
            return [NSJSONSerialization dataWithJSONObject:json
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
            
        }
    }
    
    return data;
}

+ (NSString *)stringFromIcon:(unichar)icon
{
    return [NSString stringWithFormat:@"%C", icon];
}

+ (NSString*)boolString:(BOOL)boolValue
{
    return boolValue ? [kStringTrue copy] : [kStringFalse copy];
}

- (NSString*)prependSpaceIfNeeded
{
    if ([self hasPrefix:@" "])
    {
        return self;
    }
    return [@" " stringByAppendingString:self];
}

- (NSString *)capitalizedStringForSelectors
{
    if ([self isEqualToString:@""])
    {
        return self;
    }
    NSRange rangeForFirstChar = NSMakeRange(0, 1);
    NSString *substringFirstChar = [self substringWithRange:rangeForFirstChar];

    return [self stringByReplacingCharactersInRange:rangeForFirstChar withString:[substringFirstChar uppercaseString]];
}

- (NSUUID *)createUUIDFromHashingString
{
    const char *primitiveChars = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(primitiveChars, (int)strlen(primitiveChars), result);
    return [[NSUUID alloc] initWithUUIDBytes:result];
}

+ (NSString *)pageViewPathFromPageHierarchy:(NSArray<NSString *> *)pageHierarchy
{
    NSMutableString *pageName = [NSMutableString new];
    
    for (int i = 0; i < pageHierarchy.count; ++i)
    {
        NSString *name = [pageHierarchy objectAtIndex:i];
        
        MHVASSERT_TRUE(![NSString isNilOrEmpty:name], @"name cannot be nil or empty.");
        
        if (i != 0)
        {
            [pageName appendString:@"/"];
        }
        
        [pageName appendString:name];
    }
    
    return pageName;
}

- (BOOL)boolValueFromString
{
    // On nil return false
    return self && ([self caseInsensitiveCompare:kStringTrue] == NSOrderedSame);
}

@end
