//
//  MHVGetServiceDefinitionTask.h
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

#import <Foundation/Foundation.h>
#import "MHVMethodCallTask.h"
#import "MHVServiceDef.h"

//
// Gets the HealthVault Service definition
// When the task completes successfully, it returns a MHVServiceDefinition object
//
@interface MHVGetServiceDefinitionTask : MHVMethodCallTask
{
@private
    MHVServiceDefinitionParams* m_params;
}
//
// Request - optional parameters
//
@property (readwrite, nonatomic, strong) MHVServiceDefinitionParams* params;

//
// Response - service definition
//
@property (readonly, nonatomic, strong) MHVServiceDefinition* serviceDef;

+(MHVGetServiceDefinitionTask *) getTopology:(HVTaskCompletion) callback;

@end
