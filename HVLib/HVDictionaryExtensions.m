//
//  HVDictionaryExtensions.m
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

#import "HVCommon.h"
#import "HVDictionaryExtensions.h"

@implementation NSDictionary (HVDictionaryExtensions)

+(BOOL)isNilOrEmpty:(NSDictionary *)dictionary
{
    return (dictionary == nil || dictionary.count == 0);
}

+(NSMutableDictionary *)fromArgumentString:(NSString *)args
{
    if ([NSString isNilOrEmpty:args])
    {
        return nil;
    }
    
    NSArray* parts = [args componentsSeparatedByString:@"&"];
    if ([NSArray isNilOrEmpty:parts])
    {
        return nil;
    }
    
    NSMutableDictionary* nvPairs = [NSMutableDictionary dictionary];
    HVCHECK_NOTNULL(nvPairs);
    
    for (NSUInteger i = 0, count = parts.count; i < count; ++i)
    {
        NSString* part = [parts objectAtIndex:i];
        if ([NSString isNilOrEmpty:part])
        {
            continue;
        }

        NSString* key = part;
        NSString* value = c_emptyString;

        NSUInteger nvSepPos = [part indexOfFirstChar:'='];
        if (nvSepPos != NSNotFound)
        {
            key = [part substringToIndex:nvSepPos];
            value = [part substringFromIndex:nvSepPos + 1]; // Handles the case where = is at the end of the string
        }

        [nvPairs setValue:value forKey:key];

    }

    return nvPairs;
    
LError:
    return nil;    
}

-(BOOL)hasKey:(id)key
{
    return ([self objectForKey:key] != nil);
}

-(BOOL)boolValueForKey:(id)key
{
    NSNumber* value = [self objectForKey:key];
    return value.boolValue;
}

@end

@implementation NSMutableDictionary (HVDictionaryExtensions)

-(void)setBoolValue:(BOOL)value forKey:(id<NSCopying>)key
{
    NSNumber* boolValue = [[NSNumber alloc] initWithBool:value];
    [self setObject:boolValue forKey:key];
}

@end
