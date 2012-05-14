//
//  HVException.m
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

#import "HVCommon.h"
#import "HVClientException.h"
#import "HVCore.h"
#import "HVValidator.h"

static NSString* const c_clientExceptionName = @"HVClientException";

@implementation HVClientException

@synthesize details = m_details;

-(NSString *)description
{
    return m_details.description;
}

+(void) throwExceptionWithError:(HVClientResult *)error
{
    HVClientException* ex = [[[HVClientException alloc] initWithName:c_clientExceptionName reason:c_emptyString userInfo:nil] autorelease];
    ex.details = error;
    
    @throw ex;
}

@end


