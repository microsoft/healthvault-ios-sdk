//
//  HVAppProvisionController.h
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

#import "HVBrowserController.h"
#import "HVClient.h"
#import "HVBlock.h"

@class HVAppProvisionController;

@interface HVAppProvisionController : HVBrowserController
{
    enum HVAppProvisionStatus m_status;
    NSError *m_error;
    HVNotify m_callback;
}

-(id) initWithAppCreateUrl:(NSURL *) url andCallback:(HVNotify) callback;

@property (readonly, nonatomic) NSError* error;
@property (readonly, nonatomic) enum HVAppProvisionStatus status;

@property (readonly, nonatomic) BOOL isSuccess;

@end
