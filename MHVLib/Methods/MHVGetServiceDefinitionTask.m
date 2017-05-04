//
//  MHVGetServiceDefinitionTask.m
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
#import "MHVGetServiceDefinitionTask.h"

@implementation MHVGetServiceDefinitionTask

@synthesize params = m_params;

-(NSString *)name
{
    return @"GetServiceDefinition";
}

-(float)version
{
    return 2;
}

-(MHVServiceDefinition *)serviceDef
{
    return (MHVServiceDefinition *) self.result;
}


-(void)prepare
{
    self.useMasterAppID = TRUE;
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    if (m_params)
    {
        [m_params serialize:writer];
    }
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVServiceDefinition class]];
}

+(MHVGetServiceDefinitionTask *)getTopology:(MHVTaskCompletion)callback
{
    MHVGetServiceDefinitionTask* task = [[MHVGetServiceDefinitionTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    MHVServiceDefinitionParams* params = [[MHVServiceDefinitionParams alloc] init];
    MHVCHECK_NOTNULL(params);
    
    [params.sections addObject:@"topology"];
    task.params = params;
    
    [task start];
    
    return task;

LError:
    return nil;
}

@end
