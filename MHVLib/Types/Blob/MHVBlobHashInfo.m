//
//  MHVBlobHashInfo.m
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
#import "MHVBlobHashInfo.h"

static NSString* const c_element_blockSize = @"block-size";
@implementation MHVBlobHashAlgorithmParams

@synthesize blockSize = m_blockSize;


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_blockSize);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_blockSize content:m_blockSize];
}

-(void)deserialize:(XReader *)reader
{
    m_blockSize = [reader readElement:c_element_blockSize asClass:[MHVPositiveInt class]];
}

@end

static NSString* const c_element_algorithm = @"algorithm";
static NSString* const c_element_params = @"params";
static NSString* const c_element_hash = @"hash";

@implementation MHVBlobHashInfo

@synthesize params = m_params;

-(NSString *)algorithm
{
    return (m_algorithm) ? m_algorithm.value : nil;
}

-(void)setAlgorithm:(NSString *)algorithm
{
    MHVENSURE(m_algorithm, MHVStringZ255);
    m_algorithm.value = algorithm;
}

-(NSString *)hash
{
    return (m_hash) ? m_hash.value : nil;
}

-(void)setHash:(NSString *)hash
{
    MHVENSURE(m_hash, MHVStringNZ512);
    m_hash.value = hash;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_algorithm, MHVClientError_InvalidBlobInfo);
    MHVVALIDATE_OPTIONAL(m_params);
    MHVVALIDATE(m_hash, MHVClientError_InvalidBlobInfo);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_algorithm content:m_algorithm];
    [writer writeElement:c_element_params content:m_params];
    [writer writeElement:c_element_hash content:m_hash];
}

-(void)deserialize:(XReader *)reader
{
    m_algorithm = [reader readElement:c_element_algorithm asClass:[MHVStringZ255 class]];
    m_params = [reader readElement:c_element_params asClass:[MHVBlobHashAlgorithmParams class]];
    m_hash = [reader readElement:c_element_hash asClass:[MHVStringNZ512 class]];
}

@end
