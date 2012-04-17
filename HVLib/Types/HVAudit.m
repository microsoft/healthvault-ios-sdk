//
//  HVAudit.m
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
#import "HVAudit.h"

static NSString* const c_element_when = @"timestamp";
static NSString* const c_element_appID = @"app-id";
static NSString* const c_element_action = @"audit-action";

@implementation HVAudit

@synthesize when = m_when;
@synthesize appID = m_appID;
@synthesize action = m_action;


-(void) dealloc
{
    [m_when release];
    [m_appID release];
    [m_action release];
    
    [super dealloc];
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_DATE(m_when, c_element_when);
    HVSERIALIZE_STRING(m_appID, c_element_appID);
    HVSERIALIZE_STRING(m_action, c_element_action);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_DATE(m_when, c_element_when);
    HVDESERIALIZE_STRING(m_appID, c_element_appID);
    HVDESERIALIZE_STRING(m_action, c_element_action);    
}

@end
