//
//  HVBlobHashInfo.m
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
#import "HVBlobHashInfo.h"

static NSString* const c_element_blockSize = @"block-size";
@implementation HVBlobHashAlgorithmParams

@synthesize blockSize = m_blockSize;

-(void)dealloc
{
    [m_blockSize release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_blockSize);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_blockSize content:m_blockSize];
}

-(void)deserialize:(XReader *)reader
{
    m_blockSize = [[reader readElement:c_element_blockSize asClass:[HVPositiveInt class]] retain];
}

@end

static NSString* const c_element_algorithm = @"algorithm";
static NSString* const c_element_params = @"params";
static NSString* const c_element_hash = @"hash";

@implementation HVBlobHashInfo

@synthesize params = m_params;

-(NSString *)algorithm
{
    return (m_algorithm) ? m_algorithm.value : nil;
}

-(void)setAlgorithm:(NSString *)algorithm
{
    HVENSURE(m_algorithm, HVStringZ255);
    m_algorithm.value = algorithm;
}

-(NSString *)hash
{
    return (m_hash) ? m_hash.value : nil;
}

-(void)setHash:(NSString *)hash
{
    HVENSURE(m_hash, HVStringNZ512);
    m_hash.value = hash;
}

-(void)dealloc  
{
    [m_algorithm release];
    [m_params release];
    [m_hash release];

    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_algorithm, HVClientError_InvalidBlobInfo);
    HVVALIDATE_OPTIONAL(m_params);
    HVVALIDATE(m_hash, HVClientError_InvalidBlobInfo);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_algorithm content:m_algorithm];
    [writer writeElement:c_element_params content:m_params];
    [writer writeElement:c_element_hash content:m_hash];
}

-(void)deserialize:(XReader *)reader
{
    m_algorithm = [[reader readElement:c_element_algorithm asClass:[HVStringZ255 class]] retain];
    m_params = [[reader readElement:c_element_params asClass:[HVBlobHashAlgorithmParams class]] retain];
    m_hash = [[reader readElement:c_element_hash asClass:[HVStringNZ512 class]] retain];
}

@end
