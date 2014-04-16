//
//  HVConstrainedString.m
//  HVLib
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

#import "HVCommon.h"
#import "HVConstrainedString.h"

@implementation HVString

@synthesize value = m_value;

-(NSUInteger) length
{
    return (m_value != nil) ? m_value.length : 0;
}

-(id) initWith:(NSString *)value
{
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_value, value);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_value release];
    [super dealloc];
}

-(NSString *) description
{
    return m_value;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_TEXT(m_value);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TEXT(m_value);
}

@end


@implementation HVConstrainedString

-(NSUInteger) minLength
{
    return 1;
}

-(NSUInteger) maxLength
{
    return INT32_MAX;
}

-(HVClientResult *) validate
{
    HVCHECK_SUCCESS([self validateValue:m_value]);
    
    HVVALIDATE_SUCCESS;
    
LError:
    return HVMAKE_ERROR(HVClientError_ValueOutOfRange);
}

-(BOOL) validateValue:(NSString *)value
{
    int length = (value != nil) ? value.length : 0;
    return (self.minLength <= length && length <= self.maxLength);
}

@end
