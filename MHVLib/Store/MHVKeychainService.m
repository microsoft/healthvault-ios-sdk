//
// MHVKeychainService.m
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

#import "MHVCommon.h"
#import "MHVClient.h"
#import "MHVKeychainService.h"
#import <Security/Security.h>

@implementation MHVKeychainService

- (NSMutableDictionary *)attributesForKey:(NSString *)key
{
    MHVASSERT_PARAMETER(key);
    
    if (!key)
    {
        return nil;
    }

    NSMutableDictionary *attrib = [NSMutableDictionary new];

    [attrib setObject:key forKey:(id)kSecAttrGeneric];
    [attrib setObject:key forKey:(id)kSecAttrAccount];
    [attrib setObject:@"HealthVault" forKey:(id)kSecAttrService];

    return attrib;
}

- (NSMutableDictionary *)queryForKey:(NSString *)key
{
    NSMutableDictionary *query = [self attributesForKey:key];

    if (!query)
    {
        return nil;
    }

    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];

    return query;
}

- (NSData *)runQuery:(NSMutableDictionary *)query
{
    MHVASSERT_PARAMETER(query);
    
    if (!query)
    {
        return nil;
    }

    [query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];

    CFTypeRef result = nil;
    
    if (SecItemCopyMatching((CFDictionaryRef)query, &result) == errSecSuccess)
    {
        return (NSData *)CFBridgingRelease(result);
    }

    return nil;
}

- (NSData *)getDataForKey:(NSString *)key
{
    NSMutableDictionary *query = [self queryForKey:key];

    if (!query)
    {
        return nil;
    }

    return [self runQuery:query];
}

- (NSString *)stringForKey:(NSString *)key
{
    NSData *data = [self getDataForKey:key];

    if (!data || data.length == 0)
    {
        return nil;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (BOOL)setString:(NSString *)string forKey:(NSString *)key
{
    MHVASSERT_PARAMETER(key);
    
    if (!key)
    {
        return NO;
    }
    
    if ([NSString isNilOrEmpty:string])
    {
        return [self removeStringForKey:key];
    }

    NSMutableDictionary *query = [self queryForKey:key];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *update = [self attributesForKey:key];
    
    if (!query || !data || !update)
    {
        return NO;
    }

    [update setObject:data forKey:(id)kSecValueData];

    OSStatus error = 0;
    if ([self stringForKey:key] != nil)
    {
        // Update existing
        error = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)update);
    }
    else
    {
        [update setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        error = SecItemAdd((CFDictionaryRef)update, NULL);
    }

    return error == errSecSuccess;
}

- (BOOL)removeStringForKey:(NSString *)key
{
    MHVASSERT_PARAMETER(key);
    
    if (!key)
    {
        return NO;
    }
    
    NSMutableDictionary *query = [self queryForKey:key];
    
    if (!query)
    {
        return NO;
    }

    OSStatus error = SecItemDelete((CFDictionaryRef)query);

    return error == errSecSuccess;
}

@end
