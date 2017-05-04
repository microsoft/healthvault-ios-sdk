//
//  MHVBlobPutParameters.m
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
#import "MHVBlobPutParameters.h"

static NSString* const c_element_blockSize = @"block-size";

@implementation MHVBlobHashAlgorithmParameters

@synthesize blockSize = m_blockSize;

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_blockSize intValue:(int)m_blockSize];
}

-(void)deserialize:(XReader *)reader
{
    m_blockSize = [reader readIntElement:c_element_blockSize];
}

@end

static NSString* const c_element_url = @"blob-ref-url";
static NSString* const c_element_chunkSize = @"blob-chunk-size";
static NSString* const c_element_maxSize = @"max-blob-size";
static NSString* const c_element_hashAlg = @"blob-hash-algorithm";
static NSString* const c_element_hashParams = @"blob-hash-parameters";

@implementation MHVBlobPutParameters

@synthesize url = m_url;
@synthesize chunkSize = m_chunkSize;
@synthesize maxSize = m_maxSize;
@synthesize hashAlgorithm = m_hashAlgorithm;
@synthesize hashParams = m_hashParams;


-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_url value:m_url];
    [writer writeElement:c_element_chunkSize intValue:(int)m_chunkSize];
    [writer writeElement:c_element_maxSize intValue:(int)m_maxSize];
    [writer writeElement:c_element_hashAlg value:m_hashAlgorithm];
    [writer writeElement:c_element_hashParams content:m_hashParams];
}

-(void)deserialize:(XReader *)reader
{
    m_url = [reader readStringElement:c_element_url];
    m_chunkSize = [reader readIntElement:c_element_chunkSize];
    m_maxSize = [reader readIntElement:c_element_maxSize];
    m_hashAlgorithm = [reader readStringElement:c_element_hashAlg];
    m_hashParams = [reader readElement:c_element_hashParams asClass:[MHVBlobHashAlgorithmParameters class]];    
}

@end
