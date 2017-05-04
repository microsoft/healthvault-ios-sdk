//
//  MHVBeginBlobPut.m
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
#import "MHVBeginBlobPutTask.h"
#import "MHVBlobPutParameters.h"

@implementation MHVBeginBlobPutTask

-(NSString *)name
{
    return @"BeginPutBlob";
}

-(float)version
{
    return 1;
}

-(void)prepare
{
    [self ensureRecord];
}

-(MHVBlobPutParameters *)putParams
{
    return (MHVBlobPutParameters *) self.result;
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    // Empty request body
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [self deserializeResponseBodyFromReader:reader asClass:[MHVBlobPutParameters class]];
}
@end
