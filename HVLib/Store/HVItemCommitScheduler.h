//
//  HVItemCommitScheduler.h
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

#import <Foundation/Foundation.h>
#import "HVAsyncTask.h"
#import "HVLocalVault.h"
#import "HVNetworkReachability.h"

@interface HVItemCommitScheduler : NSObject
{
@private
    HVLocalVault* m_localVault;
    HVWorkerStatus* m_status;
    NSTimer* m_timer;
    HVTask* m_activeCommitTask;

    NSTimeInterval m_commitFrequency;
    BOOL m_checkNetwork;
}

@property (readonly, nonatomic) BOOL isBusy;
// DISABLED by default. You must explictly enable the scheduler for it to start
@property (readwrite, nonatomic) BOOL isEnabled;

// If commitFrequency is > 0, a background timer is set up to periodically commit changes to HealthVault
@property (readonly, nonatomic) NSTimeInterval commitFrequency;
// False by default
@property (readwrite, nonatomic) BOOL checkNetworkAvailability;


//
// Create schedulers that run with the given frequency.
// A freq <= 0 means that commits are only on demand--when you can startCommits
// The scheduler is DISABLED by default, and won't run unless you explicitly enable it
//
-(id) initWithFrequency:(NSTimeInterval) freq;
-(id) initWithFrequency:(NSTimeInterval)freq forLocalVault:(HVLocalVault *) vault;

//
// Call commitChanges to start commits on demand...
// You can also set the commitFrequency to enable a background timer
//
-(void) commitChanges;
-(void) cancelActiveCommits;

-(void) handleException:(id) ex;

@end
