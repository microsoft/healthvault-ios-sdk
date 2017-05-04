//
//  MHVClient.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MHVBlock.h"
#import "MHVClientSettings.h"
#import "MHVDirectory.h"
#import "HealthVaultService.h"
#import "MHVRecord.h"
#import "MHVLocalVault.h"
#import "MHVUser.h"
#import "MHVServiceDef.h"
#import "MHVMethodFactory.h"
#import "MHVNetworkReachability.h"

enum MHVAppProvisionStatus 
{
    MHVAppProvisionCancelled = 0,
    MHVAppProvisionSuccess = 1,
    MHVAppProvisionFailed = 2,
};

@class MHVAppProvisionController;

//-------------------------
//
// HealthVault Client
// You always work with the .current singleton.
// The singleton represents your client application.
//
// *IMPORTANT*
// MHVClient will automatically loads configuration settings from a resource file
// named ClientSettings.xml
//
//-------------------------
@interface MHVClient : NSObject
{
@private
    NSOperationQueue *m_queue;
    
    MHVClientSettings *m_settings;
    MHVDirectory *m_rootDirectory;
    id<HealthVaultService> m_service;
    MHVServiceDefinition* m_serviceDef;
    MHVEnvironmentSettings* m_environment;
    //
    // Provisioning
    //
    UIViewController *m_parentController;
    enum MHVAppProvisionStatus m_provisionStatus;
    MHVNotify m_provisionCallback;
    //
    // Records and other local storage
    //
    MHVLocalVault *m_localVault;
    MHVUser *m_user;
    
    MHVMethodFactory* m_methodFactory;
}

//-------------------------
//
// THE Singleton you always work with
// The SDK will automatically create and manage the singleton for you.
// It will read your application's configuration from the ClientSettings.xml file.
//
// You can also chose to initialize the client manually.
// If so, you must do so as part of your application's startup code
//
//-------------------------
+(MHVClient *) current;
+(BOOL) initializeClientUsingSettings:(MHVClientSettings *) settings;

@property (strong, readonly, nonatomic) MHVClientSettings* settings;
@property (strong, readonly, nonatomic) MHVLocalVault *localVault;
@property (strong, readonly, nonatomic) MHVDirectory* rootDirectory;
@property (strong, readonly, nonatomic) MHVEnvironmentSettings* environment;

@property (readonly, nonatomic) enum MHVAppProvisionStatus provisionStatus;
@property (readonly, nonatomic) BOOL isProvisioned;
//
// Is the app created in HealthVault
//
@property (readonly, nonatomic) BOOL isAppCreated;

@property (readonly, nonatomic) id<HealthVaultService> service;
@property (strong, readonly, nonatomic) MHVUser* user;
@property (readonly, nonatomic) BOOL hasUser;
@property (strong, readonly, nonatomic) MHVRecordCollection* records;
@property (strong, readonly, nonatomic) MHVRecord* currentRecord;
@property (readonly, nonatomic) BOOL hasAuthorizedRecords;

@property (readwrite, nonatomic, strong) MHVMethodFactory* methodFactory;

//-------------------------
//
// Startup and provisioning
// You must ALWAYS call this method when starting your application
// It will ensure that your application is provisioned and has access
// to at least one user record
//
// Note: Your UIViewController MUST have a navigation controller
// The method may push a new viewcontroller that will take your app through HealthVault authorization
//
//-------------------------  
-(BOOL) startWithParentController:(UIViewController *) controller andStartedCallback:(MHVNotify) callback;

//
// See MHVUser for user specific methods
// See MHVRecordReference for record specific methods
// You can also look at the Methods folder
//

//-------------------------
//
// Methods
//
//-------------------------
//
// MHVClient maintains a background operation/task queue
//
-(void) queueOperation:(NSOperation *) op;
//
// State management - use these when your app is being rehydrated/put to sleep
//
-(BOOL) loadState;
-(BOOL) saveState;
-(BOOL) deleteState;
//
// After this call, app will no longer be provisioned
// All local state will be deleted, including anything stored on disk. 
// You will need to re-provision the app (by calling startWithParentController)...
//
-(BOOL) resetProvisioning;
-(BOOL) resetLocalVault;

-(BOOL) isCurrentRecord:(MHVRecord *) record;

//-------------------------
//
// Storage
//
//-------------------------
-(MHVLocalRecordStore *) getCurrentRecordStore;
-(void) didReceiveMemoryWarning;


@end
