//
//  HVIndexList.mm
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
#import "HVIndexList.h"

@implementation HVIndexList

-(NSUInteger)count
{
    return m_list.count;
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_list = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_list);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    HVCHECK_SELF;
    
    m_list = [[NSMutableArray alloc] initWithCapacity:capacity];
    HVCHECK_NOTNULL(m_list);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_list release];
    [super dealloc];
}

-(NSUInteger)valueAt:(NSUInteger)index
{
    NSNumber* num = [m_list objectAtIndex:index];
    return num.unsignedIntegerValue;
}

-(void)add:(NSUInteger)value
{
    [m_list addObject:[NSNumber numberWithUnsignedInteger:value]];
}

@end
