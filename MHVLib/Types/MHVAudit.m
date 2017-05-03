//
//  MHVAudit.m
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

#import "MHVCommon.h"
#import "MHVAudit.h"

static NSString* const c_element_when = @"timestamp";
static NSString* const c_element_appID = @"app-id";
static NSString* const c_element_action = @"audit-action";

@implementation MHVAudit

@synthesize when = m_when;
@synthesize appID = m_appID;
@synthesize action = m_action;



-(void) serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when dateValue:m_when];
    [writer writeElement:c_element_appID value:m_appID];
    [writer writeElement:c_element_action value:m_action];
}

-(void) deserialize:(XReader *)reader
{
    m_when = [reader readDateElement:c_element_when];
    m_appID = [reader readStringElement:c_element_appID];
    m_action = [reader readStringElement:c_element_action];    
}

@end
