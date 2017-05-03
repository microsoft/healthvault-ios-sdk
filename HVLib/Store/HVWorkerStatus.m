//
//  HVWorkerStatus.m
//  HVLib
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
#import "HVCommon.h"
#import "HVWorkerStatus.h"

@implementation HVWorkerStatus

@synthesize isEnabled = m_isEnabled;
@synthesize isBusy = m_isBusy;

-(id)init
{
    if (!(self = [super init])) return nil;
    HVCHECK_SELF;
    
    m_isBusy = FALSE;
    m_hasPendingWork = FALSE;
    m_isEnabled = TRUE;
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(BOOL)beginWork
{
    @synchronized(self)
    {
        if (m_isBusy || !m_isEnabled)
        {
            m_hasPendingWork = TRUE;
            return FALSE;
        }
        
        m_isBusy = TRUE;
        return TRUE;
    }
}

-(BOOL)completeWork
{
    @synchronized(self)
    {
        m_isBusy = FALSE;
        BOOL isPending = m_hasPendingWork;
        m_hasPendingWork = FALSE;
        return isPending;
    }
}

-(BOOL)shouldScheduleWork
{
    @synchronized(self)
    {
        if (m_isBusy || !m_isEnabled)
        {
            m_hasPendingWork = TRUE;
            return FALSE;
        }
        
        return TRUE;
    }
}

@end
