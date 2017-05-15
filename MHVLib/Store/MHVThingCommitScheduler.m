//
//  MHVThingCommitScheduler.m
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
//

#import "MHVCommon.h"
#import "MHVClient.h"
#import "MHVThingCommitScheduler.h"

@interface MHVThingCommitScheduler (MHVPrivate)

-(void) setActiveTask:(MHVTask *) task;
-(void) commitChangesComplete:(MHVTask *) task;

-(BOOL) startTimer;
-(void) stopTimer;
-(void) timerTick;

-(BOOL) isServiceReachable;

@end

@implementation MHVThingCommitScheduler

-(BOOL)isBusy
{
    return m_status.isBusy;
}
-(BOOL)isEnabled
{
    @synchronized(self)
    {
        return m_status.isEnabled;
    }
}
-(void)setIsEnabled:(BOOL)enabled
{
    @synchronized(self)
    {
        m_status.isEnabled = enabled;
        if (enabled)
        {
            [self startTimer];
        }
        else
        {
            [self stopTimer];
            [self cancelActiveCommits];
        }
    }
}

@synthesize commitFrequency = m_commitFrequency;
@synthesize checkNetworkAvailability = m_checkNetwork;

-(id)init
{
    // By default, no 'auto' background commits
    return [self initWithFrequency:0];
}

-(id)initWithFrequency:(NSTimeInterval)freq
{
    return [self initWithFrequency:freq forLocalVault:[MHVClient current].localVault];
}

-(id)initWithFrequency:(NSTimeInterval)freq forLocalVault:(MHVLocalVault *)vault
{
    MHVCHECK_NOTNULL(vault);

    self = [super init];
    MHVCHECK_SELF;
    
    m_localVault = vault;
    
    m_status = [[MHVWorkerStatus alloc] init];
    MHVCHECK_NOTNULL(m_status);
    
    m_status.isEnabled = FALSE;
    m_commitFrequency = freq;
    m_checkNetwork = FALSE;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)commitChanges
{
    if (!self.isServiceReachable)
    {
        // Network problems
        return;
    }
    
    if (![m_status beginWork])
    {
        // Already working
        return;
    }
    
    @try
    {
        MHVTask* task = [m_localVault commitOfflineChangesWithCallback:^(MHVTask *task) {
            
            [self commitChangesComplete:task];
            
        }];
        
        if (task)
        {
            [self setActiveTask:task];
        }
    }
    @catch (id ex)
    {
        [self handleException:ex];
    }
}

-(void)cancelActiveCommits
{
    @synchronized(m_activeCommitTask)
    {
        if (m_activeCommitTask)
        {
            [m_activeCommitTask cancel];
        }
        m_activeCommitTask = nil;
    }
    [m_status completeWork];
}

-(void)handleException:(id)ex
{
    [ex log];
}

@end

@implementation MHVThingCommitScheduler (MHVPrivate)

-(void)setActiveTask:(MHVTask *)task
{
    @synchronized(self)
    {
        m_activeCommitTask = task;
    }
}

-(void)commitChangesComplete:(MHVTask *)task
{
    @try
    {
        BOOL hasPendingWork = [m_status completeWork];
        
        [task checkSuccess];
        [self setActiveTask:nil];
        
        if (hasPendingWork)
        {
            [self commitChanges];
        }
    }
    @catch (id ex)
    {
        [self handleException:ex];
    }
}

//
// Creates a non-repeating timer that fires once
//
-(BOOL)startTimer
{
    @synchronized(self)
    {
        if (m_timer)
        {
            return TRUE;
        }
        
        if (m_commitFrequency > 0)
        {
            //
            // We'll let the timer run without break...
            // If there are intermittent failures, we are ensured that eventually the timer will force us to retry
            //
            m_timer = [NSTimer scheduledTimerWithTimeInterval:m_commitFrequency
                                    target:self
                                    selector:@selector(timerTick)
                                    userInfo:nil
                                    repeats:TRUE];
            
            MHVCHECK_NOTNULL(m_timer);
        }
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(void)stopTimer
{
    @synchronized(self)
    {
        if (m_timer)
        {
            [m_timer invalidate];
        }
        m_timer = nil;
    }
}

-(void)timerTick
{
    [self commitChanges];
}

-(BOOL)isServiceReachable
{
    if (!m_checkNetwork)
    {
        return TRUE;
    }
    
    return [[MHVClient current].environment isServiceNetworkReachable];
}

@end
