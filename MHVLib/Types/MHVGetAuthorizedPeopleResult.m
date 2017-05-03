//
//  HVGetAuthorizedPeopleResults.m
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
#import "MHVGetAuthorizedPeopleResult.h"

static NSString* const c_element_results = @"response-results";
static NSString* const c_element_person = @"person-info";
static NSString* const c_element_more = @"more-results";

@implementation MHVGetAuthorizedPeopleResult

@synthesize persons = m_persons;
@synthesize moreResults = m_moreResults;


-(void)serialize:(XWriter *)writer
{
    [writer writeStartElement:c_element_results];
    
    [writer writeElementArray:c_element_results itemName:c_element_person elements:m_persons];
    [writer writeElement:c_element_more content:m_moreResults];
    
    [writer writeEndElement];
}

-(void)deserialize:(XReader *)reader
{
    [reader  readStartElementWithName:c_element_results];
    
    m_persons = [reader readElementArray:c_element_person asClass:[MHVPersonInfo class]];
    m_moreResults = [reader readElement:c_element_more asClass:[MHVBool class]];
    
    [reader readEndElement];
}

@end
