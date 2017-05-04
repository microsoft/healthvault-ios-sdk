//
//  MHVRemoveRecordAuthTask.m
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
//

#import "MHVCommon.h"
#import "MHVRemoveRecordAuthTask.h"

@implementation MHVRemoveRecordAuthTask

-(NSString *)name
{
    return @"RemoveApplicationRecordAuthorization";
}

-(float)version
{
    return 1;
}

-(id)initWithRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    self.record = record;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)prepare
{
    [self ensureRecord];
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [reader readInnerXml];
}

@end
