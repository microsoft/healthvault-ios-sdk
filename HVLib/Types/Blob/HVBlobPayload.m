//
//  HVBlobPayload.m
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
#import "HVBlobPayload.h"

static NSString* const c_element_blob = @"blob";

@implementation HVBlobPayload

-(HVBlobPayloadItemCollection *) items
{
    HVENSURE(m_blobItems, HVBlobPayloadItemCollection);
    return m_blobItems;
}

-(BOOL)hasItems
{
    return ![NSArray isNilOrEmpty:m_blobItems];
}

-(void)dealloc
{
    [m_blobItems release];
    [super dealloc];
}

-(HVBlobPayloadItem *)getDefaultBlob
{
    return [self getBlobNamed:c_emptyString];
}

-(HVBlobPayloadItem *)getBlobNamed:(NSString *)name
{
    if (!self.hasItems)
    {
        return nil;
    }
    
    return [m_blobItems getBlobNamed:name];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_blobItems, HVClientError_InvalidBlobInfo);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_blobItems, c_element_blob);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_blobItems, c_element_blob, HVBlobPayloadItem, HVBlobPayloadItemCollection);
}

@end
