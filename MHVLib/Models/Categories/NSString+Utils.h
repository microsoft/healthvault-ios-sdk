//
// NSString+Utils.h
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

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSString *)stringByRemovingHTMLTags;
+ (NSString *)stringFromNumber:(NSNumber*)number;
+ (NSNumber *)numberFromString:(NSString *)string;
+ (NSString *)stringFromInt:(NSInteger)number;
+ (NSInteger)intFromString:(NSString *)string;
+ (NSString *)stringFromIntSigned:(NSInteger)number;
+ (NSString *)stringByRoundingUpDistance:(double)distance decimals:(NSInteger)decimals;
+ (NSString *)stringFromDouble:(double)number decimals:(NSInteger)decimals;
+ (NSString *)stringFromDouble:(double)number decimals:(NSInteger)decimals stripTrailingZeros:(BOOL)stripTrailingZeros;
+ (NSString *)stringFromDoubleDistance:(double)distance;
+ (NSString *)stringFromDouble:(double)number decimals:(NSInteger)decimals stripTrailingZeros:(BOOL)stripTrailingZeros roundingMode:(NSNumberFormatterRoundingMode)roundingMode;
+ (NSString *)roundedDecimalLimitedStringFromDouble:(double)number decimals:(NSInteger)decimals roundingMode:(NSNumberFormatterRoundingMode)roundingMode;

/**
 * Converts to big endian UUID.
 */
- (NSUUID *)toBigEndianUUID;

- (NSString *)substringToIndexUTFSafe:(NSUInteger)to;
- (NSString *)substringFromIndexUTFSafe:(NSUInteger)from;
- (NSString *)substringToStringWithMaxBytes:(NSUInteger)maxBytes;
+ (BOOL)isNilOrEmpty:(NSString *)string;
- (NSString*)uppercaseStringLocalized;

+ (NSString*)stringFromDoubleDistanceGolf:(double)distance;
- (BOOL)containsSubString:(NSString *)string;
- (BOOL)containsSubStringCaseInsensative:(NSString *)string;
- (NSString *)obfuscatedString;
- (NSString *)substringFromString:(NSString *)startString toString:(NSString *)endString;
- (NSData *)prettyPrintedJsonData;

+ (NSString *)stringFromIcon:(unichar)icon;

+ (NSString*)boolString:(BOOL)boolValue;
- (NSString*)prependSpaceIfNeeded;
- (NSString *)capitalizedStringForSelectors;
- (NSUUID *)createUUIDFromHashingString;

+ (NSString *)pageViewPathFromPageHierarchy:(NSArray<NSString *> *)pageHierarchy;

/**
 * Parse boolean strings into bool value
 * @return Boolean value of the string. Returns YES if string is "true" (case insensitive), returns NO for anything else 
 */
- (BOOL)boolValueFromString;

@end
