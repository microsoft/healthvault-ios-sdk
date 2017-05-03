//
//  HVBlobPayloadItem.m
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
//

#import "HVCommon.h"
#import "HVBlobPayloadItem.h"

static NSString* const c_element_blobInfo = @"blob-info";
static NSString* const c_element_length = @"content-length";
static NSString* const c_element_blobUrl = @"blob-ref-url";
static NSString* const c_element_legacyEncoding = @"legacy-content-encoding";
static NSString* const c_element_currentEncoding = @"current-content-encoding";

@implementation HVBlobPayloadItem

@synthesize blobInfo = m_blobInfo;
@synthesize length = m_length;
@synthesize blobUrl = m_blobUrl;

-(NSString *)name
{
    return (m_blobInfo) ? m_blobInfo.name : c_emptyString;
}

-(NSString *)contentType
{
    return (m_blobInfo) ? m_blobInfo.contentType : c_emptyString;
}

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_length = -1;
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(id)initWithBlobName:(NSString *)name contentType:(NSString *)contentType length:(NSInteger)length andUrl:(NSString *)blobUrl
{
    HVCHECK_STRING(blobUrl);
    
    self = [self init];
    HVCHECK_SELF;
    
    m_blobInfo = [[HVBlobInfo alloc] initWithName:name andContentType:contentType];
    HVCHECK_NOTNULL(m_blobInfo);
    
    m_length = length;
   
    m_blobUrl = [blobUrl retain];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_blobInfo release];
    [m_blobUrl release];
    [m_legacyEncoding release];
    [m_encoding release];
    
    [super dealloc];
}

-(HVHttpResponse *)createDownloadTaskWithCallback:(HVTaskCompletion)callback
{
    NSURL* url = [NSURL URLWithString:m_blobUrl];
    HVCHECK_NOTNULL(url);
    
    return [[[HVHttpResponse alloc] initWithUrl:url andCallback:callback] autorelease];

LError:
    return nil;
}

-(HVHttpResponse *)downloadWithCallback:(HVTaskCompletion)callback
{
    HVHttpResponse* response = [self createDownloadTaskWithCallback:callback];
    HVCHECK_NOTNULL(response);
    
    [response start];
    
    return response;

LError:
    return nil;
}

-(HVHttpDownload *)downloadToFilePath:(NSString *)path andCallback:(HVTaskCompletion)callback
{
    return [self downloadToFile:[NSFileHandle fileHandleForWritingAtPath:path] andCallback:callback];
}

-(HVHttpDownload *)downloadToFile:(NSFileHandle *)file andCallback:(HVTaskCompletion)callback
{
    NSURL* url = [NSURL URLWithString:m_blobUrl];
    HVCHECK_NOTNULL(url);
    
    HVHttpDownload* response = [[[HVHttpDownload alloc] initWithUrl:url fileHandle:file andCallback:callback] autorelease];
    [response start];
    
    return response;
    
LError:
    return nil;    
}

-(HVClientResult *)validate
{   
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_blobInfo, HVClientError_InvalidBlobInfo);
    HVVALIDATE_STRING(m_blobUrl, HVClientError_InvalidBlobInfo);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_blobInfo content:m_blobInfo];
    [writer writeElement:c_element_length intValue:(int)m_length];
    [writer writeElement:c_element_blobUrl value:m_blobUrl];
    [writer writeElement:c_element_legacyEncoding value:m_legacyEncoding];
    [writer writeElement:c_element_currentEncoding value:m_encoding];
}

-(void)deserialize:(XReader *)reader
{
    m_blobInfo = [[reader readElement:c_element_blobInfo asClass:[HVBlobInfo class]] retain];
    m_length = [reader readIntElement:c_element_length];
    m_blobUrl = [[reader readStringElement:c_element_blobUrl] retain];
    m_legacyEncoding = [[reader readStringElement:c_element_legacyEncoding] retain];
    m_encoding = [[reader readStringElement:c_element_currentEncoding] retain];
}

@end

@implementation HVBlobPayloadItemCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVBlobPayloadItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVBlobPayloadItem *)itemAtIndex:(NSUInteger)index
{
    return (HVBlobPayloadItem *) [self objectAtIndex:index];
}

-(NSUInteger)indexofDefaultBlob
{
    return [self indexOfBlobNamed:c_emptyString];
}

-(NSUInteger)indexOfBlobNamed:(NSString *)name
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        HVBlobPayloadItem* item = [self itemAtIndex:i];
        NSString* blobName = item.name;
        if ([blobName isEqualToString:name])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(HVBlobPayloadItem *)getDefaultBlob
{
    NSUInteger index = [self indexofDefaultBlob];
    if (index != NSNotFound)
    {
        return [self itemAtIndex:index];
    }
    
    return nil;
}

-(HVBlobPayloadItem *)getBlobNamed:(NSString *)name
{
    NSUInteger index = [self indexOfBlobNamed:name];
    if (index != NSNotFound)
    {
        return [self itemAtIndex:index];
    }
    
    return nil;    
}

@end
