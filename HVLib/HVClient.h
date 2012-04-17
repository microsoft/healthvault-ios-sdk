//
//  HVClient.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HVBlock.h"
#import "HVClientSettings.h"
#import "HVDirectory.h"
#import "HealthVaultService.h"
#import "HVRecord.h"
#import "HVLocalVault.h"
#import "HVUser.h"

enum HVAppProvisionStatus 
{
    HVAppProvisionCancelled = 0,
    HVAppProvisionSuccess = 1,
    HVAppProvisionFailed = 2,
};

@class HVAppProvisionController;

@interface HVClient : NSObject
{
    NSOperationQueue *m_queue;
    
    HVClientSettings *m_settings;
    HVDirectory *m_rootDirectory;
    HealthVaultService *m_service;
    //
    // Provisioning
    //
    UIViewController *m_parentController;
    enum HVAppProvisionStatus m_provisionStatus;
    HVNotify m_provisionCallback;
    //
    // Records and other local storage
    //
    HVLocalVault *m_localVault;
    HVUser *m_user;
}

+(HVClient *) current;

@property (readonly, nonatomic) HVClientSettings* settings;
@property (readonly, nonatomic) HVLocalVault *localVault;
@property (readonly, nonatomic) enum HVAppProvisionStatus provisionStatus;
@property (readonly, nonatomic) BOOL isProvisioned;

@property (readonly, nonatomic) HealthVaultService* service;
@property (readonly, nonatomic) HVUser* user;
@property (readonly, nonatomic) HVRecordCollection* records;
@property (readonly, nonatomic) HVRecord* currentRecord;

-(void) queueOperation:(NSOperation *) op;

//
// Startup and provisioning
//
-(BOOL) startWithParentController:(UIViewController *) controller andStartedCallback:(HVNotify) callback;
//
// Common healthvault methods
//

//
// State management
//
-(BOOL) loadState;
-(BOOL) saveState;
-(BOOL) deleteState;

@end
