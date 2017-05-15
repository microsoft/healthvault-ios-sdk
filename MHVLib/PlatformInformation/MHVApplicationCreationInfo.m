//
//  MHVApplicationCreationInfo.m
//  MHVLib
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

#import "MHVApplicationCreationInfo.h"

static NSString *const c_element_appId = @"app-id";
static NSString *const c_element_sharedSecret = @"shared-secret";
static NSString *const c_element_appToken = @"app-token";

@implementation MHVApplicationCreationInfo

- (void)deserialize:(XReader *)reader
{
    
}

- (void)deserializeAttributes:(XReader *)reader
{
    _appInstanceId = [reader readStringElement:c_element_appId];
    _sharedSecret = [reader readStringElement:c_element_sharedSecret];
    _appCreationToken = [reader readStringElement:c_element_appToken];
}

- (void)serialize:(XWriter *)writer
{
    
}

- (void)serializeAttributes:(XWriter *)writer
{
    
}

@end
