//
//  HVVocabSearchText.m
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

#import "HVCommon.h"
#import "HVVocabSearchText.h"

NSString* HVVocabMatchTypeToString(enum HVVocabMatchType type)
{
    switch (type) {
        case HVVocabMatchTypeFullText:
            return @"FullText";
        
        case HVVocabMatchTypePrefix:
            return @"Prefix";
            
        default:
            break;
    }
    
    return c_emptyString;
}

enum HVVocabMatchType HVVocabMatchTypeFromString(NSString* string)
{
    if ([string isEqualToString:@"FullText"])
    {
        return HVVocabMatchTypeFullText;
    }
    
    if ([string isEqualToString:@"Prefix"])
    {
        return HVVocabMatchTypePrefix;
    }
    
    return HVVocabMatchTypeNone;
}

static NSString* const c_attribute_matchType = @"search-mode";

@implementation HVVocabSearchText

@synthesize matchType = m_type;

-(void)serializeAttributes:(XWriter *)writer
{
    NSString* matchType = HVVocabMatchTypeToString(m_type);
    
    [writer writeAttribute:c_attribute_matchType value:matchType];
}

-(void)deserializeAttributes:(XReader *)reader
{
    NSString* mode = nil;

    mode = [[reader readAttribute:c_attribute_matchType] retain];
    if (![NSString isNilOrEmpty:mode])
    {
        m_type = HVVocabMatchTypeFromString(mode);
    }
}

@end
