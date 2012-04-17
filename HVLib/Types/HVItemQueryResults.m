//
//  HVItemQueryResults.m
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
#import "HVItemQueryResults.h"

static NSString* const c_element_result = @"group";

@implementation HVItemQueryResults

@synthesize results = m_results;

-(BOOL) hasResults
{
    return !([NSArray isNilOrEmpty:m_results]);
}

-(HVItemQueryResult *)firstResult
{
    return (m_results) ? [m_results objectAtIndex:0] : nil;
}

-(void) dealloc
{
    [m_results release];
    [super dealloc];
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_results, c_element_result);
}

-(void) deserialize:(XReader *)reader
{
     HVDESERIALIZE_TYPEDARRAY(m_results, c_element_result, HVItemQueryResult, HVItemQueryResultCollection);
}

@end
