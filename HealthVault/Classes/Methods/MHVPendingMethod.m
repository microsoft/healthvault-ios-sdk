//
// MHVPendingMethod.m
// healthvault-ios-sdk
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

#import "MHVPendingMethod.h"

@implementation MHVPendingMethod

@synthesize name = _name;
@synthesize version = _version;
@synthesize parameters = _parameters;
@synthesize recordId = _recordId;
@synthesize correlationId = _correlationId;

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                     method:(MHVMethod *)method
{
    self = [super init];
    
    if (self)
    {
        _originalRequestDate = originalRequestDate;
        _name = method.name;
        _version = method.version;
        _parameters = method.parameters;
        _recordId = method.recordId;
        _correlationId = method.correlationId;

    }
    
    return self;
}

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                 methodName:(NSString *)methodName
{
    self = [super init];
    
    if (self)
    {
        _originalRequestDate = originalRequestDate;
        _name = methodName;
    }
    
    return self;
}

@end
