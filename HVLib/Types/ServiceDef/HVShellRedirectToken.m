//
//  HVShellRedirectToken.m
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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
//

#import "HVCommon.h"
#import "HVShellRedirectToken.h"

static const xmlChar* x_element_token = XMLSTRINGCONST("token");
static const xmlChar* x_element_descr = XMLSTRINGCONST("description");
static const xmlChar* x_element_queryString = XMLSTRINGCONST("querystring-parameters");

@implementation HVShellRedirectToken

@synthesize token = m_token;
@synthesize description = m_description;
@synthesize queryStringParams = m_queryStringParams;

-(void)dealloc
{
    [m_token release];
    [m_description release];
    [m_queryStringParams release];
    
    [super dealloc];
}

-(void)deserialize:(XReader *)reader
{
    
}

@end
