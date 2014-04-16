//
//  HVUITaskAwareViewController.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
#import "HVCommon.h"
#import "HVUITaskAwareViewController.h"

@implementation HVUITaskAwareViewController

-(HVTask *)activeTask
{
    return m_activeTask;
}

-(void)setActiveTask:(HVTask *)activeTask
{
    [self cancelActiveTask];
    HVRETAIN(m_activeTask, activeTask);
}

-(BOOL)hasActiveTask
{
    return (m_activeTask && !m_activeTask.isDone);
}

-(void)dealloc
{
    [m_activeTask release];
    [super dealloc];
}

-(void)cancelActiveTask
{
    if (m_activeTask)
    {
        [m_activeTask cancel];
        HVCLEAR(m_activeTask);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        [self cancelActiveTask];
        [self viewWillClose];
    }
    
    [super viewWillDisappear:animated];
}

-(void)viewWillClose
{
    
}

@end
