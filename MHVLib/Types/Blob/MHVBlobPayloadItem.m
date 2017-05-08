//
// MHVBlobPayloadItem.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVBlobPayloadItem.h"

static NSString *const c_element_blobInfo = @"blob-info";
static NSString *const c_element_length = @"content-length";
static NSString *const c_element_blobUrl = @"blob-ref-url";
static NSString *const c_element_legacyEncoding = @"legacy-content-encoding";
static NSString *const c_element_currentEncoding = @"current-content-encoding";

@interface MHVBlobPayloadItem ()

@property (nonatomic, strong) NSString *legacyEncoding;
@property (nonatomic, strong) NSString *encoding;

@end

@implementation MHVBlobPayloadItem

- (NSString *)name
{
    return (self.blobInfo) ? self.blobInfo.name : c_emptyString;
}

- (NSString *)contentType
{
    return (self.blobInfo) ? self.blobInfo.contentType : c_emptyString;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _length = -1;
    }

    return self;
}

- (instancetype)initWithBlobName:(NSString *)name contentType:(NSString *)contentType length:(NSInteger)length andUrl:(NSString *)blobUrl
{
    MHVCHECK_STRING(blobUrl);

    self = [self init];
    if (self)
    {
        _blobInfo = [[MHVBlobInfo alloc] initWithName:name andContentType:contentType];
        MHVCHECK_NOTNULL(_blobInfo);

        _length = length;

        _blobUrl = blobUrl;
    }

    return self;
}

- (MHVHttpResponse *)createDownloadTaskWithCallback:(MHVTaskCompletion)callback
{
    NSURL *url = [NSURL URLWithString:self.blobUrl];

    MHVCHECK_NOTNULL(url);

    return [[MHVHttpResponse alloc] initWithUrl:url andCallback:callback];

   LError:
    return nil;
}

- (MHVHttpResponse *)downloadWithCallback:(MHVTaskCompletion)callback
{
    MHVHttpResponse *response = [self createDownloadTaskWithCallback:callback];

    MHVCHECK_NOTNULL(response);

    [response start];

    return response;
}

- (MHVHttpDownload *)downloadToFilePath:(NSString *)path andCallback:(MHVTaskCompletion)callback
{
    return [self downloadToFile:[NSFileHandle fileHandleForWritingAtPath:path] andCallback:callback];
}

- (MHVHttpDownload *)downloadToFile:(NSFileHandle *)file andCallback:(MHVTaskCompletion)callback
{
    NSURL *url = [NSURL URLWithString:self.blobUrl];

    MHVCHECK_NOTNULL(url);

    MHVHttpDownload *response = [[MHVHttpDownload alloc] initWithUrl:url fileHandle:file andCallback:callback];
    [response start];

    return response;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE(self.blobInfo, MHVClientError_InvalidBlobInfo);
    MHVVALIDATE_STRING(self.blobUrl, MHVClientError_InvalidBlobInfo);

    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_blobInfo content:self.blobInfo];
    [writer writeElement:c_element_length intValue:(int)self.length];
    [writer writeElement:c_element_blobUrl value:self.blobUrl];
    [writer writeElement:c_element_legacyEncoding value:self.legacyEncoding];
    [writer writeElement:c_element_currentEncoding value:self.encoding];
}

- (void)deserialize:(XReader *)reader
{
    self.blobInfo = [reader readElement:c_element_blobInfo asClass:[MHVBlobInfo class]];
    self.length = [reader readIntElement:c_element_length];
    self.blobUrl = [reader readStringElement:c_element_blobUrl];
    self.legacyEncoding = [reader readStringElement:c_element_legacyEncoding];
    self.encoding = [reader readStringElement:c_element_currentEncoding];
}

@end

@implementation MHVBlobPayloadItemCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVBlobPayloadItem class];
    }

    return self;
}

- (MHVBlobPayloadItem *)itemAtIndex:(NSUInteger)index
{
    return (MHVBlobPayloadItem *)[self objectAtIndex:index];
}

- (NSUInteger)indexofDefaultBlob
{
    return [self indexOfBlobNamed:c_emptyString];
}

- (NSUInteger)indexOfBlobNamed:(NSString *)name
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        MHVBlobPayloadItem *item = [self itemAtIndex:i];
        NSString *blobName = item.name;
        if ([blobName isEqualToString:name])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (MHVBlobPayloadItem *)getDefaultBlob
{
    NSUInteger index = [self indexofDefaultBlob];

    if (index != NSNotFound)
    {
        return [self itemAtIndex:index];
    }

    return nil;
}

- (MHVBlobPayloadItem *)getBlobNamed:(NSString *)name
{
    NSUInteger index = [self indexOfBlobNamed:name];

    if (index != NSNotFound)
    {
        return [self itemAtIndex:index];
    }

    return nil;
}

@end
