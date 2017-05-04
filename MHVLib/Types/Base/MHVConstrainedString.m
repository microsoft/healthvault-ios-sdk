//
//  MHVConstrainedString.m
//  MHVLib
//
//  Copyright (c) 2012, 2014 Microsoft Corporation. All rights reserved.
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
#import "MHVConstrainedString.h"

@implementation MHVString

@synthesize value = m_value;

-(NSUInteger) length
{
    return (m_value != nil) ? m_value.length : 0;
}

-(id) initWith:(NSString *)value
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_value = value;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSString *) description
{
    return m_value;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeText:m_value];
}

-(void) deserialize:(XReader *)reader
{
    m_value = [reader readValue];
}

@end


@implementation MHVConstrainedString

-(NSUInteger) minLength
{
    return 1;
}

-(NSUInteger) maxLength
{
    return INT32_MAX;
}

-(MHVClientResult *) validate
{
    if ([self validateValue:m_value])
    {
        return MHVRESULT_SUCCESS;
    }
    else
    {
        return MHVMAKE_ERROR(MHVClientError_ValueOutOfRange);
    }
}

-(BOOL) validateValue:(NSString *)value
{
    int length = (value != nil) ? (int)value.length : 0;
    return (self.minLength <= length && length <= self.maxLength);
}

@end
