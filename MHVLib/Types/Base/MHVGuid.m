//
// MHVGuid.m
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

#import "MHVCommon.h"
#import "MHVGuid.h"

@implementation MHVGuid

- (instancetype)initWithNewUuid
{
    self = [self initWithUuid:[NSUUID UUID]];

    MHVCHECK_SELF;

    return self;
}

- (instancetype)initWithUuid:(NSUUID *)uuid
{
    MHVCHECK_NOTNULL(uuid);

    self = [super init];
    MHVCHECK_SELF;

    _value = uuid;

    return self;
}

- (instancetype)initFromString:(NSString *)string
{
    NSUUID *uuidValue = [[NSUUID alloc] initWithUUIDString:string];

    MHVCHECK_NOTNULL(uuidValue);

    self = [self initWithUuid:uuidValue];

    MHVCHECK_SELF;

    return self;
}

- (BOOL)hasValue
{
    return self.value != nil;
}

- (void)deserialize:(XReader *)reader
{
    self.value = [reader readUuid];
}

- (void)serialize:(XWriter *)writer
{
    if (self.hasValue)
    {
        [writer writeUuid:self.value];
    }
}

- (NSString *)description
{
    return [self.value UUIDString];
}

- (MHVClientResult *)validate
{
    if (!self.value)
    {
        return MHVMAKE_ERROR(MHVClientError_InvalidGuid);
    }

    return MHVRESULT_SUCCESS;
}

@end
