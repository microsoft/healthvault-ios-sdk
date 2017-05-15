//
//  MHVThingCommitScheduler.h
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

#import <Foundation/Foundation.h>
#import "MHVAsyncTask.h"
#import "MHVLocalVault.h"

//--------------------------------------------------------------
//
// Background worker that periodically commits pending changes to MHVSynchronizedTypes
// back to HealthVault
//
// The application manages the lifetime of this object.
// You create an MHVThingCommitScheduler and give it an optional frequency at which it should run.
// You retain a reference to the scheduler while your application is running.
//
// **IMPORTANT**
// The scheduler must be ENABLED for it to start committing changes
// The scheduler is DISABLED by default.
// You can enable/disable the scheduler as you see fit.
//
//--------------------------------------------------------------
@interface MHVThingCommitScheduler : NSObject
{
@private
    MHVLocalVault* m_localVault;
    MHVWorkerStatus* m_status;
    NSTimer* m_timer;
    MHVTask* m_activeCommitTask;

    NSTimeInterval m_commitFrequency;
    BOOL m_checkNetwork;
}

//
// The scheduler is DISABLED by default.
// You must explictly enable the scheduler for it to start
//
@property (readwrite, nonatomic) BOOL isEnabled;

// Is the scheduler currently working...
@property (readonly, nonatomic) BOOL isBusy;
// If commitFrequency is > 0, a background timer is set up to periodically commit changes to HealthVault
@property (readonly, nonatomic) NSTimeInterval commitFrequency;
// False by default
@property (readwrite, nonatomic) BOOL checkNetworkAvailability;

//--------------
//
// Initializers
//
//--------------
//
// Create schedulers that run with the given frequency.
// A freq <= 0 means that commits are only on demand--when you can startCommits
// The scheduler is DISABLED by default, and won't run unless you explicitly enable it
//
-(id) initWithFrequency:(NSTimeInterval) freq;
-(id) initWithFrequency:(NSTimeInterval)freq forLocalVault:(MHVLocalVault *) vault;

//--------------
//
// Initializers
//
//--------------
//
// Typically, this is called by a background timer.
// You can also call these methods on DEMAND, to immediately start the commit
// If a commit is already in progress, then this nothing.
//
-(void) commitChanges;
-(void) cancelActiveCommits;
//
// Applications can override this
//
-(void) handleException:(id) ex;

@end
