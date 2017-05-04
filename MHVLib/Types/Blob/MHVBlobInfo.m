//
//  MHVBlobInfo.m
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
#import "MHVCommon.h"
#import "MHVBlobInfo.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_contentType = @"content-type";

@implementation MHVBlobInfo

-(NSString *)name
{
    NSString* blobName = (m_name) ? m_name.value : nil;
    return (blobName) ? blobName : c_emptyString;
}

-(void)setName:(NSString *)name
{
    MHVENSURE(m_name, MHVStringZ255);    
    m_name.value = name;
}

-(NSString *)contentType
{
    return (m_contentType) ? m_contentType.value : nil;
}

-(void)setContentType:(NSString *)contentType
{
    MHVENSURE(m_contentType, MHVStringZ1024);
    m_contentType.value = contentType;
}

-(id)initWithName:(NSString *)name andContentType:(NSString *)contentType
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.name = name;
    self.contentType = contentType;
    
    MHVCHECK_NOTNULL(m_name);
    MHVCHECK_NOTNULL(m_contentType);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_name);
    MHVVALIDATE_OPTIONAL(m_contentType);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_contentType content:m_contentType];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVStringZ255 class]];
    m_contentType = [reader readElement:c_element_contentType asClass:[MHVStringZ1024 class]];
}


@end
