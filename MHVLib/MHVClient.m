//
// MHVClient.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVClient.h"
#import "HealthVaultResponse.h"
#import "MHVAppProvisionController.h"
#import "MHVServiceDef.h"
#import "MHVMethods.h"

static MHVClient *s_client;
static NSString *const c_userfileName = @"user.xml";
static NSString *const c_environmentFileName = @"environment.xml";

@interface MHVClient ()

@property (readwrite, nonatomic, strong) NSOperationQueue *queue;

@property (readwrite, nonatomic, strong) id<HealthVaultService>     service;
@property (readwrite, nonatomic, strong) MHVServiceDefinition *serviceDef;
@property (readwrite, nonatomic, strong) MHVLocalVault *localVault;
@property (readwrite, nonatomic, strong) MHVDirectory *rootDirectory;
@property (readwrite, nonatomic, strong) MHVUser *user;

@property (readwrite, nonatomic, weak)   UIViewController *parentController;

@property (readwrite, nonatomic, assign) MHVAppProvisionStatus provisionStatus;
@property (readwrite, nonatomic, strong) MHVNotify provisionCallback;

@end

@implementation MHVClient

+ (void)initialize
{
    static dispatch_once_t s_clientToken = 0;
    
    dispatch_once(&s_clientToken, ^
                  {
                      MHVClientSettings *settings = [MHVClientSettings newDefault];
                      s_client = [[MHVClient alloc] initWithSettings:settings];
                  });
}

+ (MHVClient *)current
{
    return s_client;
}

+ (BOOL)initializeClientUsingSettings:(MHVClientSettings *)settings
{
    MHVCHECK_NOTNULL(settings);
    
    s_client = [[MHVClient alloc] initWithSettings:settings];
    return s_client != nil;
}

- (instancetype)init
{
    return [self initWithSettings:nil];
}

- (void)dealloc
{
    [self unsubscribeAppEvents];
}

- (BOOL)isProvisioned
{
    return [self isAppCreated] && self.user && self.user.hasRecords;
}

- (BOOL)isAppCreated
{
    return [self.service isAppCreated];
}

- (BOOL)hasUser
{
    return self.user != nil;
}

- (MHVRecordCollection *)records
{
    return (self.user) ? self.user.records : nil;
}

- (MHVRecord *)currentRecord
{
    return (self.user) ? self.user.currentRecord : nil;
}

- (BOOL)hasAuthorizedRecords
{
    return ![MHVCollection isNilOrEmpty:self.records];
}

- (BOOL)startWithParentController:(UIViewController *)controller andStartedCallback:(MHVNotify)callback
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(controller);
        MHVCHECK_NOTNULL(callback);
        MHVCHECK_NOTNULL(controller.navigationController);
        
        self.parentController = controller;
        
        self.provisionCallback = [callback copy];
        
        [self loadState];
        
        if (self.isProvisioned)
        {
            // Already provisioned.
            self.provisionStatus = MHVAppProvisionSuccess;
            [self notifyOfProvisionStatus];
        }
        else
        {
            // Have to provision this application - perhaps authorize some records
            [self deleteState];
            [self.service applyEnvironmentSettings:[self.settings firstEnvironment]];
            
            [self beginAuth];
        }
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

- (void)queueOperation:(NSOperation *)op
{
    [self.queue addOperation:op];
}

- (BOOL)loadState
{
    @synchronized(self)
    {
        if (self.service)
        {
            [self.service loadSettings];
        }
        
        self.user = [self loadUser]; // ok if this is null
        
        if (![self applyUserEnvironment])
        {
            self.user = nil; // Can no longer guarantee this user's settings
        }
        
        return TRUE;
    }
}

- (BOOL)saveState
{
    @synchronized(self)
    {
        [self.service saveSettings];
        [self saveEnvironment];
        
        return [self saveUser];
    }
}

- (BOOL)deleteState
{
    @synchronized(self)
    {
        [self deleteSavedEnvironment];
        [self deleteUser];
        
        if (self.service)
        {
            [self.service reset];
            [self.service saveSettings];
        }
        
        return TRUE;
    }
}

- (BOOL)resetProvisioning
{
    @synchronized(self)
    {
        self.provisionStatus = MHVAppProvisionCancelled;
        //
        // Delete local state
        //
        [self deleteState];
        //
        // And local storage
        //
        [self resetLocalVault];
        
        self.service = [self newService];
        MHVCHECK_NOTNULL(self.service);
        
        [self.service saveSettings];
        
        return TRUE;
    }
}

- (BOOL)resetLocalVault
{
    @synchronized(self)
    {
        if (!self.localVault)
        {
            return TRUE;
        }
        
        [MHVDirectory deleteUrl:self.rootDirectory.url];
        
        self.rootDirectory = nil;
        self.localVault = nil;
        
        MHVCHECK_SUCCESS([self ensureLocalVault]); // So the MHVClient object remains in valid state
        
        return TRUE;
    }
}

- (BOOL)isCurrentRecord:(MHVRecord *)record
{
    if (!record)
    {
        return FALSE;
    }
    
    return self.currentRecord && [self.currentRecord.ID isEqualToString:record.ID];
}

- (MHVLocalRecordStore *)getCurrentRecordStore
{
    return [self.localVault getRecordStore:self.currentRecord];
}

- (void)didReceiveMemoryWarning
{
    if (self.localVault)
    {
        [self.localVault didReceiveMemoryWarning];
    }
}

- (instancetype)initWithSettings:(MHVClientSettings *)settings
{
    MHVCHECK_NOTNULL(settings);
    
    self = [super init];
    if (self)
    {
        _queue = [[NSOperationQueue alloc] init];
        MHVCHECK_NOTNULL(_queue);
        
        _settings = settings;
        MHVCHECK_SUCCESS([self ensureLocalVault]);
        
        // Set up the HealthVault Service
        _service = [self newService];
        MHVCHECK_NOTNULL(_service);
        
        _methodFactory = [[MHVMethodFactory alloc] init];
        
        [self initializeState];
        [self subscribeAppEvents];
    }
    
    return self;
}

- (void)initializeState
{
    [self loadState];
    if (self.hasAuthorizedRecords)
    {
        self.provisionStatus = MHVAppProvisionSuccess;
    }
}

- (BOOL)ensureLocalVault
{
    if (!self.rootDirectory)
    {
        if (self.settings.rootDirectoryPath)
        {
            self.rootDirectory = [[MHVDirectory alloc] initWithPath:self.settings.rootDirectoryPath];
        }
        else
        {
            self.rootDirectory = [[MHVDirectory alloc] initWithRelativePath:@"HealthVault"];
        }
        
        MHVCHECK_NOTNULL(self.rootDirectory);
    }
    
    if (!self.localVault)
    {
        self.localVault = [[MHVLocalVault alloc] initWithRoot:self.rootDirectory andCache:self.settings.useCachingInStore];
        MHVCHECK_NOTNULL(self.localVault);
    }
    
    return TRUE;
}

- (void)updateUser
{
    @synchronized(self)
    {
        //
        // Capture authorized records
        //
        if (self.user)
        {
            [self.user updateWithLegacyRecords:self.service.records];
        }
        else
        {
            self.user = [[MHVUser alloc] initFromLegacyRecords:self.service.records];
            if (self.environment)
            {
                self.user.instanceID = self.environment.instanceID;
            }
        }
    }
}

- (MHVUser *)loadUser
{
    @synchronized(self)
    {
        MHVUser *user = [self.localVault.root getObjectWithKey:c_userfileName name:@"user" andClass:[MHVUser class]];
        
        if (user && [user validate].isError)
        {
            [self deleteUser];
            user = nil;
        }
        
        if (user)
        {
            [user configureCurrentRecordForService:self.service];
        }
        
        return user;
    }
}

- (void)setUser:(MHVUser *)user
{
    @synchronized(self)
    {
        _user = user;
    }
}

- (BOOL)saveUser
{
    @synchronized(self)
    {
        if (!self.user)
        {
            return TRUE;
        }
        
        return [self.localVault.root putObject:self.user withKey:c_userfileName andName:@"user"];
    }
}

- (void)deleteUser
{
    @synchronized(self)
    {
        [self.localVault.root deleteKey:c_userfileName];
        self.user = nil;
    }
}

- (BOOL)applyUserEnvironment
{
    if (!self.hasUser)
    {
        return TRUE;
    }
    
    NSString *userEnvironment = self.user.environment;
    if ([NSString isNilOrEmpty:userEnvironment])
    {
        return TRUE;
    }
    
    MHVEnvironmentSettings *environment = [self.settings environmentWithName:userEnvironment];
    if (environment)
    {
        [self.service applyEnvironmentSettings:environment];
        return TRUE;
    }
    
    // User's current environment not found
    return FALSE;
}

- (void)loadSavedEnvironment
{
    @synchronized(self)
    {
        _environment = (MHVEnvironmentSettings *)[self.localVault.root getObjectWithKey:c_environmentFileName name:@"environment" andClass:[MHVEnvironmentSettings class]];
    }
}

- (BOOL)saveEnvironment
{
    @synchronized(self)
    {
        if (!self.environment)
        {
            return TRUE;
        }
        
        return [self.localVault.root putObject:self.environment withKey:c_environmentFileName andName:@"environment"];
    }
}

- (void)makeEnvironmentWithInstance:(MHVInstance *)instance
{
    @synchronized(self)
    {
        _environment = nil;
        
        if (instance)
        {
            _environment = [MHVEnvironmentSettings fromInstance:instance];
        }
        
        [self.service applyEnvironmentSettings:self.environment];
    }
}

- (void)deleteSavedEnvironment
{
    @synchronized(self)
    {
        _environment = nil;
        
        [self.localVault.root deleteKey:c_environmentFileName];
    }
}

- (HealthVaultService *)newService
{
    MHVEnvironmentSettings *environment = nil;
    
    [self loadSavedEnvironment];
    if (self.environment)
    {
        environment = self.environment;
    }
    else
    {
        environment = [self.settings firstEnvironment];
    }
    
    HealthVaultService *service = [[HealthVaultService alloc] initForAppID:self.settings.masterAppID
                                                            andEnvironment:environment];
    
    MHVCHECK_NOTNULL(service);
    
    service.country = self.settings.country;
    service.language = self.settings.language;
    service.deviceName = self.settings.deviceName;
    if (self.settings.autoRequestDelay > 0)
    {
        service.requestSendDelay = self.settings.autoRequestDelay;
    }
    
    return service;
}

- (void)shellAuthRequired:(HealthVaultResponse *)response
{
    if (self.settings.isMultiInstanceAware)
    {
        [self invokeOnMainThread:@selector(beginGetTopology)];
    }
    else
    {
        [self invokeOnMainThread:@selector(beginShellAuth)];
    }
}

- (void)beginAuth
{
    [self.service performAuthenticationCheck:self authenticationCompleted:@selector(authenticationCompleted:) shellAuthRequired:@selector(shellAuthRequired:)];
}

- (void)beginShellAuth
{
    [self saveState];
    
    self.provisionStatus = MHVAppProvisionCancelled;
    
    NSURL *creationUrl;
    if (self.settings.isMultiInstanceAware)
    {
        creationUrl = [NSURL URLWithString:[self.service getApplicationCreationUrlGA]];
    }
    else
    {
        creationUrl = [NSURL URLWithString:[self.service getApplicationCreationUrl]];
    }
    
    if (!creationUrl)
    {
        safeInvokeNotify(self.provisionCallback, self);
        return;
    }
    
    MHVAppProvisionController *shellController = [[MHVAppProvisionController alloc] initWithAppCreateUrl:creationUrl andCallback:^(MHVAppProvisionController *controller)
                                                  {
                                                      if (controller.status == MHVAppProvisionSuccess)
                                                      {
                                                          if (self.settings.isMultiInstanceAware && controller.hasInstanceID)
                                                          {
                                                              [self setupInstanceInfo:controller.hvInstanceID];
                                                          }
                                                          
                                                          [self invokeOnMainThread:@selector(beginAuth)];
                                                      }
                                                      else
                                                      {
                                                          [self invokeOnMainThread:@selector(notifyOfProvisionStatus)];
                                                      }
                                                  }];
    
    if (!shellController)
    {
        safeInvokeNotify(self.provisionCallback, self);
        return;
    }
    
    [self.parentController.navigationController pushViewController:shellController animated:TRUE];
    
    return;
}

- (void)beginGetTopology
{
    MHVGetServiceDefinitionTask *getTask = [MHVGetServiceDefinitionTask getTopology:^(MHVTask *task) {
        MHVServiceDefinition *serviceDef = (((MHVGetServiceDefinitionTask *)task).serviceDef);
        self.serviceDef = serviceDef;
        
        [self invokeOnMainThread:@selector(beginShellAuth)];
    }];
    
    if (!getTask)
    {
        safeInvokeNotify(self.provisionCallback, self);
        return;
    }
}

- (void)authenticationCompleted:(HealthVaultResponse *)response
{
    //
    // Ensure that we have an authorized record
    //
    if (response && response.hasError)
    {
        self.provisionStatus = MHVAppProvisionFailed;
    }
    else
    {
        self.provisionStatus = MHVAppProvisionSuccess;
        //
        // Capture authorized records
        //
        [self updateUser];
    }
    
    [self saveState];
    self.parentController = nil;
    
    [self invokeOnMainThread:@selector(notifyOfProvisionStatus)];
}

- (void)setupInstanceInfo:(NSString *)instanceID
{
    NSUInteger index = NSNotFound;
    
    if (self.serviceDef)
    {
        index = [self.serviceDef.systemInstances.instances indexOfInstanceWithID:instanceID];
    }
    
    if (index == NSNotFound)
    {
        [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_UnknownServiceInstance)];
    }
    
    MHVInstance *instance = (MHVInstance *)[self.serviceDef.systemInstances.instances objectAtIndex:index];
    
    [self makeEnvironmentWithInstance:instance];
    [self saveState];
    
    self.serviceDef = nil;
}

- (void)notifyOfProvisionStatus
{
    safeInvokeNotify(self.provisionCallback, self);
}

- (void)subscribeAppEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)unsubscribeAppEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:[UIApplication sharedApplication]];
}

@end
