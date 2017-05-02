//
//  HVResponse.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
#import "HVCommon.h"
#import "HVResponse.h"

static const xmlChar* x_element_status = XMLSTRINGCONST("status");

@implementation HVResponse

@synthesize status = m_status;
@synthesize body = m_body;

-(BOOL)hasError
{
    return (m_status != nil && m_status.hasError);
}

-(void)dealloc
{
    [m_status release];
    [m_body release];
    
    [super dealloc];
}

-(void)deserialize:(XReader *)reader
{
    m_status = [[reader readElementWithXmlName:x_element_status asClass:[HVResponseStatus class]] retain];
    if (reader.isStartElement)
    {
        HVRETAIN(m_body, [reader readOuterXml]);
    }
}

@end
