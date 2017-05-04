//
//  MHVInstance.m
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
//
//

#import "MHVCommon.h"
#import "MHVInstance.h"

static const xmlChar* x_element_id = XMLSTRINGCONST("id");
static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_description = XMLSTRINGCONST("description");
static const xmlChar* x_element_platform = XMLSTRINGCONST("platform-url");
static const xmlChar* x_element_shell = XMLSTRINGCONST("shell-url");

@implementation MHVInstance

@synthesize instanceID = m_id;
@synthesize name = m_name;
@synthesize instanceDescription = m_description;
@synthesize platformUrl = m_platformUrl;
@synthesize shellUrl = m_shellUrl;


-(void)deserialize:(XReader *)reader
{
    m_id = [reader readStringElementWithXmlName:x_element_id];
    m_name = [reader readStringElementWithXmlName:x_element_name];
    m_description = [reader readStringElementWithXmlName:x_element_description];
    m_platformUrl = [reader readStringElementWithXmlName:x_element_platform];
    m_shellUrl = [reader readStringElementWithXmlName:x_element_shell];
}


-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_id value:m_id];
    [writer writeElementXmlName:x_element_name value:m_name];
    [writer writeElementXmlName:x_element_description value:m_description];
    [writer writeElementXmlName:x_element_platform value:m_platformUrl];
    [writer writeElementXmlName:x_element_shell value:m_shellUrl];
}

@end

@implementation MHVInstanceCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVInstance class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVInstance *)indexOfInstance:(NSUInteger)index
{
    return (MHVInstance *) [self objectAtIndex:index];
}

-(NSInteger) indexOfInstanceNamed:(NSString *)name
{
    return [self indexOfMatchingObject:^BOOL(id value) {
        return [((MHVInstance *) value).name isEqualToString:name];
    }];
}

-(NSInteger) indexOfInstanceWithID:(NSString *)instanceID
{
    return [self indexOfMatchingObject:^BOOL(id value) {
        return [((MHVInstance *) value).instanceID isEqualToString:instanceID];
    }];
}

@end
