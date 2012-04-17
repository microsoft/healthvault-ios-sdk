//
//  HVName.m
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
#import "HVName.h"

static NSString* const c_element_fullName = @"full";
static NSString* const c_element_title = @"title";
static NSString* const c_element_first = @"first";
static NSString* const c_element_middle = @"middle";
static NSString* const c_element_last = @"last";
static NSString* const c_element_suffix = @"suffix";

@implementation HVName

@synthesize fullName = m_full;
@synthesize title = m_title;
@synthesize first = m_first;
@synthesize middle = m_middle;
@synthesize last = m_last;
@synthesize suffix = m_suffix;

-(void)dealloc
{
    [m_full release];
    [m_title release];
    [m_first release];
    [m_middle release];
    [m_last release];
    [m_suffix release];
     
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return m_full;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRING(m_full, HVClientError_InvalidName);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_full, c_element_fullName);
    HVSERIALIZE(m_title, c_element_title);
    HVSERIALIZE_STRING(m_first, c_element_first);
    HVSERIALIZE_STRING(m_middle, c_element_middle);
    HVSERIALIZE_STRING(m_last, c_element_last);
    HVSERIALIZE(m_suffix, c_element_suffix);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_full, c_element_fullName);
    HVDESERIALIZE(m_title, c_element_title, HVCodableValue);
    HVDESERIALIZE_STRING(m_first, c_element_first);
    HVDESERIALIZE_STRING(m_middle, c_element_middle);
    HVDESERIALIZE_STRING(m_last, c_element_last);
    HVDESERIALIZE(m_suffix, c_element_suffix, HVCodableValue);
}

@end
