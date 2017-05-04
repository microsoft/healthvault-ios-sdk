//
//  MHVMessageAttachment.m
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
#import "MHVMessageAttachment.h"

static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_blob = XMLSTRINGCONST("blob-name");
static const xmlChar* x_element_inline = XMLSTRINGCONST("inline-display");
static const xmlChar* x_element_contentid = XMLSTRINGCONST("content-id");

@implementation MHVMessageAttachment

@synthesize name = m_name;
@synthesize blobName = m_blobName;
@synthesize isInline = m_isInline;
@synthesize contentID = m_contentID;

-(id)initWithName:(NSString *)name andBlobName:(NSString *)blobName
{
    MHVCHECK_STRING(name);
    MHVCHECK_STRING(blobName);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = name;
    m_blobName = blobName;
    m_isInline = FALSE;
    m_contentID = nil;
    
    return self;

LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_STRING(m_name, MHVClientError_InvalidMessageAttachment);
    MHVVALIDATE_STRING(m_blobName, MHVClientError_InvalidMessageAttachment);
    
    MHVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_name value:m_name];
    [writer writeElementXmlName:x_element_blob value:m_blobName];
    [writer writeElementXmlName:x_element_inline boolValue:m_isInline];
    [writer writeElementXmlName:x_element_contentid value:m_contentID];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readStringElementWithXmlName:x_element_name];
    m_blobName = [reader readStringElementWithXmlName:x_element_blob];
    m_isInline = [reader readBoolElementXmlName:x_element_inline];
    m_contentID = [reader readStringElementWithXmlName:x_element_contentid];
}

@end

@implementation MHVMessageAttachmentCollection

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVMessageAttachment class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVMessageAttachment *)itemAtIndex:(NSUInteger)index
{
    return (MHVMessageAttachment *) [self objectAtIndex:index];
}

@end


