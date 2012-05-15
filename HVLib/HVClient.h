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

//-------------------------
//
// HealthVault Client
// Use the "current" singleton. It represents the client application.
//
//-------------------------
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

//-------------------------
//
// Singelton you should work with
//
//-------------------------
+(HVClient *) current;


@property (readonly, nonatomic) HVClientSettings* settings;
@property (readonly, nonatomic) HVLocalVault *localVault;
@property (readonly, nonatomic) enum HVAppProvisionStatus provisionStatus;
@property (readonly, nonatomic) BOOL isProvisioned;

@property (readonly, nonatomic) HealthVaultService* service;
@property (readonly, nonatomic) HVUser* user;
@property (readonly, nonatomic) HVRecordCollection* records;
@property (readonly, nonatomic) HVRecord* currentRecord;

//-------------------------
//
// Startup and provisioning
// You must ALWAYS call this method when starting your application
// It will ensure that your application is provisioned and has access
// to at least one user record
//
//-------------------------
-(BOOL) startWithParentController:(UIViewController *) controller andStartedCallback:(HVNotify) callback;

//
// See HVUser for user specific methods
// See HVRecordReference for record specific methods
// You can also look at the Methods folder
//

//-------------------------
//
// Methods
//
//-------------------------
//
// HVClient maintains a background operation/task queue
//
-(void) queueOperation:(NSOperation *) op;
//
// State management - use these when your app is being rehydrated/put to sleep
//
-(BOOL) loadState;
-(BOOL) saveState;
-(BOOL) deleteState;

-(HVLocalRecordStore *) getCurrentRecordStore;

@end
