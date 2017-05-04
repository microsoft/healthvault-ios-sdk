//
//  MHVKeyChain.m
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

#import "MHVCommon.h"
#import "MHVClient.h"
#import "MHVKeyChain.h"

@implementation MHVKeyChain

+(NSMutableDictionary *) attributesForPasswordName:(NSString *)passwordName
{
    MHVCHECK_STRING(passwordName);
    
    NSMutableDictionary* attrib = [NSMutableDictionary dictionary];
    MHVCHECK_NOTNULL(attrib);
    
    [attrib setObject:passwordName forKey:(id)kSecAttrGeneric];
    [attrib setObject:passwordName forKey:(id) kSecAttrAccount];
    [attrib setObject:@"HealthVault" forKey:(id) kSecAttrService];
 
    return attrib;
    
LError:
    return nil;
}

+(NSMutableDictionary *)queryForPasswordName:(NSString *)passwordName
{
    NSMutableDictionary* query = [MHVKeyChain attributesForPasswordName:passwordName];
    MHVCHECK_NOTNULL(query);
    
    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    return query;
    
LError:
    return nil;
}

+(NSData *)runQuery:(NSMutableDictionary *)query
{
    MHVCHECK_NOTNULL(query);
    
    [query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    CFTypeRef result = nil;
    if (SecItemCopyMatching((CFDictionaryRef) query, &result) == errSecSuccess)
    {
        return (NSData *)CFBridgingRelease(result);
    }
    
LError:
    return nil;
}

+(NSData *)getPassword:(NSString *)passwordName
{
    NSMutableDictionary* query = [MHVKeyChain queryForPasswordName:passwordName];
    MHVCHECK_NOTNULL(query);
    
    return [MHVKeyChain runQuery:query];
    
LError:
    return nil;
}

+(NSString *)getPasswordString:(NSString *)passwordName
{
    NSData* password = [MHVKeyChain getPassword:passwordName];
    if (!password || password.length == 0)
    {
        return nil;
    }
    
    NSString* string = [[NSString alloc] initWithData:password encoding:NSUTF8StringEncoding];
    return string;
    
LError:
    return nil;
}

+(BOOL)setPassword:(NSString *)password forName:(NSString *)passwordName
{
    if ([NSString isNilOrEmpty:password])
    {
        return [MHVKeyChain removePassword:passwordName];
    }
    
    NSMutableDictionary* query = [MHVKeyChain queryForPasswordName:passwordName];
    MHVCHECK_NOTNULL(query);

    NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    MHVCHECK_NOTNULL(passwordData);

    NSMutableDictionary* update = [MHVKeyChain attributesForPasswordName:passwordName];
    MHVCHECK_NOTNULL(update);
    
    [update setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus error = 0;
    if ([self getPasswordString:passwordName] != nil)
    {
        // Update existing
        error = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef) update);
    }
    else
    {
        [update setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];   
        error = SecItemAdd((CFDictionaryRef)update, NULL);
    }
    
    return (error == errSecSuccess);
    
LError:
    return FALSE;
}

+(BOOL)removePassword:(NSString *)passwordName
{
    NSMutableDictionary* query = [MHVKeyChain queryForPasswordName:passwordName];
    MHVCHECK_NOTNULL(query);
    
    OSStatus error = SecItemDelete((CFDictionaryRef) query);
    
    return (error == errSecSuccess);
    
LError:
    return FALSE;
}

@end
