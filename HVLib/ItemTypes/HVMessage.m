//
//  HVMessage.m
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

#import "HVCommon.h"
#import "HVMessage.h"

static NSString* const c_typeid = @"72dc49e1-1486-4634-b651-ef560ed051e5";
static NSString* const c_typename = @"message";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static NSString* const c_element_headers = @"headers";
static const xmlChar* x_element_size = XMLSTRINGCONST("size");
static const xmlChar* x_element_summary = XMLSTRINGCONST("summary");
static const xmlChar* x_element_htmlBlob = XMLSTRINGCONST("html-blob-name");
static const xmlChar* x_element_textBlob = XMLSTRINGCONST("text-blob-name");
static NSString* const c_element_attachments = @"attachments";

@implementation HVMessage

@synthesize when = m_when;
@synthesize headers = m_headers;
@synthesize size = m_size;
@synthesize summary = m_summary;
@synthesize htmlBlobName = m_htmlBlobName;
@synthesize textBlobName = m_textBlobName;
@synthesize attachments = m_attachments;

-(BOOL)hasHeaders
{
    return (![NSArray isNilOrEmpty:m_headers]);
}

-(BOOL)hasAttachments
{
    return (![NSArray isNilOrEmpty:m_attachments]);
}

-(BOOL)hasHtmlBody
{
    return !([NSString isNilOrEmpty:m_htmlBlobName]);
}

-(BOOL)hasTextBody
{
    return !([NSString isNilOrEmpty:m_textBlobName]);
}

-(void)dealloc
{
    [m_when release];
    [m_headers release];
    [m_size release];
    [m_summary release];
    [m_htmlBlobName release];
    [m_textBlobName release];
    [m_attachments release];
    
    [super dealloc];
}

-(NSString *)getFrom
{
    return [self getValueForHeader:@"From"];
}

-(NSString *)getTo
{
    return [self getValueForHeader:@"To"];
}

-(NSString *)getSubject
{
    return [self getValueForHeader:@"Subject"];
}

-(NSString *)getCC
{
    return [self getValueForHeader:@"CC"];    
}

-(NSString *)getMessageDate
{
    return [self getValueForHeader:@"Date"];
}

-(NSString *)getValueForHeader:(NSString *)name
{
    if (!self.hasHeaders)
    {
        return nil;
    }
    
    HVMessageHeaderItem* header = [m_headers headerWithName:name];
    if (!header)
    {
        return c_emptyString;
    }
    return header.value;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];    
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidMessage);
    HVVALIDATE_ARRAYOPTIONAL(m_headers, HVClientError_InvalidMessage);
    HVVALIDATE(m_size, HVClientError_InvalidMessage);
    HVVALIDATE_ARRAYOPTIONAL(m_attachments, HVClientError_InvalidMessage);
    
    HVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementArray:c_element_headers elements:m_headers];
    [writer writeElementXmlName:x_element_size content:m_size];
    [writer writeElementXmlName:x_element_summary value:m_summary];
    [writer writeElementXmlName:x_element_htmlBlob value:m_htmlBlobName];
    [writer writeElementXmlName:x_element_textBlob value:m_textBlobName];
    [writer writeElementArray:c_element_attachments elements:m_attachments];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElementWithXmlName:x_element_when asClass:[HVDateTime class]] retain];
    m_headers = (HVMessageHeaderItemCollection *)[[reader readElementArray:c_element_headers asClass:[HVMessageHeaderItem class] andArrayClass:[HVMessageHeaderItemCollection class]] retain];
    m_size = [[reader readElementWithXmlName:x_element_size asClass:[HVPositiveInt class]] retain];
    m_summary = [[reader readStringElementWithXmlName:x_element_summary] retain];
    m_htmlBlobName = [[reader readStringElementWithXmlName:x_element_htmlBlob] retain];
    m_textBlobName = [[reader readStringElementWithXmlName:x_element_textBlob] retain];
    m_attachments = (HVMessageAttachmentCollection *)[[reader readElementArray:c_element_attachments asClass:[HVMessageAttachment class] andArrayClass:[HVMessageAttachmentCollection class]] retain];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVMessage typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Message", @"Message Type Name");
}

@end
