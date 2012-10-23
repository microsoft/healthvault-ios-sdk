//
//  HVDouble.m
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
#import "HVDouble.h"

@implementation HVDouble

@synthesize value = m_value;

-(id) initWith:(double) value
{
    self = [super init];
    HVCHECK_SELF;
    
    m_value = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSString *) description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%f"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, m_value];
}

-(void) serialize:(XWriter *)writer
{
    [writer writeDouble:m_value];
}

-(void) deserialize:(XReader *)reader
{
    m_value = [reader readDouble];
}

@end
