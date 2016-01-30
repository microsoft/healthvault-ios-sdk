//
//  HVClient.m
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
#import "HVClient.h"
#import "HealthVaultResponse.h"
#import "HVAppProvisionController.h"
#import "HVServiceDef.h"
#import "HVMethods.h"

static HVClient* s_client;

@interface HVClient (HVPrivate)

-(id) initWithSettings:(HVClientSettings *) settings;

-(void) initializeState;
-(BOOL) ensureLocalVault;

-(HealthVaultService *) newService;
-(void) updateUser;
-(HVUser *) loadUser;
-(void) setUser:(HVUser *) user;
-(BOOL) saveUser;
-(void) deleteUser;
-(BOOL) applyUserEnvironment;

-(void) loadSavedEnvironment;
-(void) setEnvironment:(HVInstance *) instance;
-(BOOL) saveEnvironment;
-(void) deleteSavedEnvironment;

//
// Callbacks from HealthVaultService object
//
-(void) shellAuthRequired: (HealthVaultResponse *)response;
-(void) authenticationCompleted: (HealthVaultResponse *)response;
//
// Auth state machine
//
-(void) beginGetTopology;
-(void) beginAuth;
-(void) beginShellAuth;
-(void) setupInstanceInfo:(NSString *) instanceID;
-(void) notifyOfProvisionStatus;

-(void) subscribeAppEvents;
-(void) unsubscribeAppEvents;

@end


@implementation HVClient

@synthesize settings = m_settings;
@synthesize localVault = m_localVault;
@synthesize rootDirectory = m_rootDirectory;
@synthesize provisionStatus = m_provisionStatus;
@synthesize service = m_service;
@synthesize user = m_user;
@synthesize environment = m_environment;

+(void)initialize
{
    static dispatch_once_t s_clientToken = 0;
    dispatch_once(&s_clientToken, ^{
        s_client = nil;
        HVClientSettings* settings = [HVClientSettings newDefault];
        s_client = [[HVClient alloc] initWithSettings:settings];
        [settings release];
    });
}

+(HVClient *)current
{
    return s_client;
}

+(BOOL)initializeClientUsingSettings:(HVClientSettings *)settings
{
    HVCHECK_NOTNULL(settings);
    HVCLEAR(s_client);
 
    s_client = [[HVClient alloc] initWithSettings:settings];
    return (s_client != nil);
    
LError:
    return FALSE;
}

-(enum HVAppProvisionStatus)provisionStatus
{
    @synchronized(self)
    {
        return m_provisionStatus;
    }
}

-(void)setProvisionStatus:(enum HVAppProvisionStatus)provisionStatus
{
    @synchronized(self)
    {
        m_provisionStatus = provisionStatus;
    }    
}

-(BOOL)isProvisioned
{
    return ([self isAppCreated] && m_user && m_user.hasRecords);
}

-(BOOL)isAppCreated
{
    return [m_service isAppCreated];
}

-(BOOL)hasUser
{
    return (m_user != nil);
}

-(HVRecordCollection *)records
{
    return (m_user) ? m_user.records : nil;
}

-(HVRecord *)currentRecord
{
    return (m_user) ? m_user.currentRecord : nil;
}

-(BOOL)hasAuthorizedRecords
{
    return ![NSArray isNilOrEmpty:self.records];
}

-(HVMethodFactory *)methodFactory
{
    return m_methodFactory;
}

-(void)setMethodFactory:(HVMethodFactory *)methodFactory
{
    if (methodFactory)
    {
        HVRETAIN(m_methodFactory, methodFactory);
    }
}

- (id)init
{
    return [self instanceWithNilSettings];
}

- (id)instanceWithNilSettings
{
    return [self initWithSettings:nil];
}

-(void) dealloc
{
    [self unsubscribeAppEvents];
    
    [m_queue release];
    [m_settings release];
    [m_rootDirectory release];
    [m_service release];
    [m_environment release];
    [m_serviceDef release];
    
    [m_parentController release];
    [m_provisionCallback release];
    
    [m_localVault release];
    [m_user release];
    
    [m_methodFactory release];

    [super dealloc];
}

-(BOOL)startWithParentController:(UIViewController *)controller andStartedCallback:(HVNotify)callback
{
    @synchronized(self)
    {
        HVCHECK_NOTNULL(controller);
        HVCHECK_NOTNULL(callback);
        HVCHECK_NOTNULL(controller.navigationController); 
        
        HVRETAIN(m_parentController, controller);
        HVCLEAR(m_provisionCallback);
        
        m_provisionCallback = [callback copy];
        
        [self loadState];
        
        if (self.isProvisioned)
        {
            // Already provisioned. 
            self.provisionStatus = HVAppProvisionSuccess;
            [self notifyOfProvisionStatus];
        }
        else
        {
             // Gonna have to provision this application - perhaps authorize some records
            [self deleteState];
            [m_service applyEnvironmentSettings:[m_settings firstEnvironment]];

            [self beginAuth];
        }
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(void)queueOperation:(NSOperation *)op
{
    [m_queue addOperation:op];
}

-(BOOL)loadState
{
    @synchronized(self)
    {
        if (m_service)
        {
            [m_service loadSettings];
        }
        
        HVCLEAR(m_user);
        self.user = [self loadUser]; // ok if this is null
        
        if (![self applyUserEnvironment])
        {
            self.user = nil; // Can no longer guarantee this user's settings
        }
 
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)saveState
{
    @synchronized(self)
    {
        [m_service saveSettings];
        [self saveEnvironment];
        return [self saveUser];
    }
}

-(BOOL)deleteState
{
    @synchronized(self)
    {
        [self deleteSavedEnvironment];
        [self deleteUser];
        if (m_service)
        {
            [m_service reset];
            [m_service saveSettings];
        }
        return TRUE;
    }
}

-(BOOL)resetProvisioning
{
    @synchronized(self)
    {
        self.provisionStatus = HVAppProvisionCancelled;
        //
        // Delete local state
        //
        [self deleteState];
        //
        // And local storage
        //
        [self resetLocalVault];

        m_service = [self newService];
        HVCHECK_NOTNULL(m_service);
        
        [m_service saveSettings];
 
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)resetLocalVault
{
    @synchronized(self)
    {
        if (!m_localVault)
        {
            return TRUE;
        }

        NSURL* storeUrl = m_rootDirectory.url;
        [HVDirectory deleteUrl:storeUrl];
        
        HVCLEAR(m_rootDirectory);
        HVCLEAR(m_localVault);
        
        HVCHECK_SUCCESS([self ensureLocalVault]); // So the HVClient object remains in valid state
        
        return TRUE;
        
    LError:
        return FALSE;
    }    
}

-(BOOL)isCurrentRecord:(HVRecord *)record
{
    if (!record)
    {
        return FALSE;
    }
    
    return (self.currentRecord && [self.currentRecord.ID isEqualToString:record.ID]);
}

-(HVLocalRecordStore *)getCurrentRecordStore
{
    return [m_localVault getRecordStore:self.currentRecord];
}

-(void)didReceiveMemoryWarning
{
    if (m_localVault)
    {
        [m_localVault didReceiveMemoryWarning];
    }
}

@end

static NSString* const c_userfileName = @"user.xml";
static NSString* const c_environmentFileName = @"environment.xml";

@implementation HVClient (HVPrivate)

-(id) initWithSettings:(HVClientSettings *)settings
{
    HVCHECK_NOTNULL(settings);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_queue = [[NSOperationQueue alloc] init];
    HVCHECK_NOTNULL(m_queue);
    
    HVRETAIN(m_settings, settings);
    HVCHECK_SUCCESS([self ensureLocalVault]);
    
    // Set up the HealthVault Service
    m_service = [self newService];
    HVCHECK_NOTNULL(m_service);
    
    m_methodFactory = [[HVMethodFactory alloc] init];
    
    [self initializeState];
    [self subscribeAppEvents];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)initializeState
{
    [self loadState];
    if (self.hasAuthorizedRecords)
    {
        m_provisionStatus = HVAppProvisionSuccess;
    }
}

-(BOOL)ensureLocalVault
{
    if (!m_rootDirectory)
    {
        if (m_settings.rootDirectoryPath)
        {
            m_rootDirectory = [[HVDirectory alloc] initWithPath:m_settings.rootDirectoryPath];
        }
        else
        {
            m_rootDirectory = [[HVDirectory alloc] initWithRelativePath:@"HealthVault"];
        }
        HVCHECK_NOTNULL(m_rootDirectory);
    }
    
    if (!m_localVault)
    {
        m_localVault = [[HVLocalVault alloc] initWithRoot:m_rootDirectory andCache:m_settings.useCachingInStore];
        HVCHECK_NOTNULL(m_localVault);
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)updateUser
{
    @synchronized(self)
    {
        //
        // Capture authorized records
        //
        if (m_user)
        {
            [m_user updateWithLegacyRecords:m_service.records];
        }
        else
        {
            m_user = [[HVUser alloc] initFromLegacyRecords:m_service.records];
            if (m_environment)
            {
                m_user.instanceID = m_environment.instanceID;
            }
        }
    }
}

-(HVUser *)loadUser
{
    @synchronized(self)
    {
        HVUser *user = [m_localVault.root getObjectWithKey:c_userfileName name:@"user" andClass:[HVUser class]];
        if (user && [user validate].isError)
        {
            [self deleteUser];
            user = nil;
        }
        if (user)
        {
            [user configureCurrentRecordForService:m_service];
        }
        
        return user;
    }
}

-(void)setUser:(HVUser *)user
{
    @synchronized(self)
    {
        HVRETAIN(m_user, user);
    }
}

-(BOOL)saveUser
{
    @synchronized(self)
    {
        if (!m_user)
        {
            return TRUE;
        }
        
        return [m_localVault.root putObject:m_user withKey:c_userfileName andName:@"user"];
    }
}

-(void)deleteUser
{
    @synchronized(self)
    {
        [m_localVault.root deleteKey:c_userfileName];
        self.user = nil;
    }
}

-(BOOL)applyUserEnvironment
{
    if (!self.hasUser)
    {
        return TRUE;
    }
    
    NSString* userEnvironment = self.user.environment;
    if ([NSString isNilOrEmpty:userEnvironment])
    {
        return TRUE;
    }
    
    HVEnvironmentSettings* environment = [m_settings environmentWithName:userEnvironment];
    if (environment)
    {
        [m_service applyEnvironmentSettings:environment];
        return TRUE;
    }
    
    // User's current environment not found
    return FALSE;
}

-(void)loadSavedEnvironment
{
    @synchronized(self)
    {
        HVCLEAR(m_environment);
        
        HVEnvironmentSettings* env = (HVEnvironmentSettings *)[m_localVault.root getObjectWithKey:c_environmentFileName name:@"environment" andClass:[HVEnvironmentSettings class]];
        
        HVRETAIN(m_environment, env);
    }
}

-(BOOL)saveEnvironment
{
    @synchronized(self)
    {
        if (!m_environment)
        {
            return TRUE;
        }
        
        return [m_localVault.root putObject:m_environment withKey:c_environmentFileName andName:@"environment"];
    }
}

-(void)setEnvironment:(HVInstance *)instance
{
    @synchronized(self)
    {
        HVCLEAR(m_environment);
        if (instance)
        {
            HVRETAIN(m_environment, [HVEnvironmentSettings fromInstance:instance]);
        }
        [m_service applyEnvironmentSettings:m_environment];
    }
}

-(void)deleteSavedEnvironment
{
    @synchronized(self)
    {
        HVCLEAR(m_environment);
        [m_localVault.root deleteKey:c_environmentFileName];
    }
}

-(HealthVaultService *)newService
{
    HVEnvironmentSettings* environment = nil;

    [self loadSavedEnvironment];
    if (m_environment)
    {
        environment = m_environment;
    }
    else
    {
        environment = [m_settings firstEnvironment];
    }
    
    HealthVaultService* service = [[HealthVaultService alloc] 
                                   initForAppID:m_settings.masterAppID 
                                   andEnvironment:environment];
    
    HVCHECK_NOTNULL(service);
    
    service.country = m_settings.country;
    service.language = m_settings.language;
    service.deviceName = m_settings.deviceName;
    if (m_settings.autoRequestDelay > 0)
    {
        service.requestSendDelay = m_settings.autoRequestDelay;
    }
    
    return service;
    
LError:
    return nil;
}

-(void)shellAuthRequired:(HealthVaultResponse *)response
{
    if(m_settings.isMultiInstanceAware)
    {
        [self invokeOnMainThread:@selector(beginGetTopology)];
    }
    else
    {
        [self invokeOnMainThread:@selector(beginShellAuth)];        
    }
}

-(void)beginAuth
{
    [m_service performAuthenticationCheck:self authenticationCompleted:@selector(authenticationCompleted:) shellAuthRequired:@selector(shellAuthRequired:)];    
}

-(void)beginShellAuth
{
    [self saveState];
    
    self.provisionStatus = HVAppProvisionCancelled;
        
    NSURL* creationUrl;
    if (m_settings.isMultiInstanceAware)
    {
        creationUrl = [NSURL URLWithString:[m_service getApplicationCreationUrlGA]];
    }
    else
    {
        creationUrl = [NSURL URLWithString:[m_service getApplicationCreationUrl]];
    }
    HVCHECK_NOTNULL(creationUrl);
    
    HVAppProvisionController * shellController = [[HVAppProvisionController alloc] initWithAppCreateUrl:creationUrl andCallback:^(HVAppProvisionController *controller) {
        
        if (controller.status == HVAppProvisionSuccess)
        {
            if (m_settings.isMultiInstanceAware && controller.hasInstanceID)
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
    
    HVCHECK_NOTNULL(shellController);
    [m_parentController.navigationController pushViewController:shellController animated:TRUE];
    [shellController release];
    
    return;

LError:
    safeInvokeNotify(m_provisionCallback, self);
}

-(void)beginGetTopology
{    
    HVGetServiceDefinitionTask* getTask = [HVGetServiceDefinitionTask getTopology:^(HVTask *task) {
        
        HVServiceDefinition* serviceDef = (((HVGetServiceDefinitionTask *) task).serviceDef);
        HVRETAIN(m_serviceDef, serviceDef);
        
        [self invokeOnMainThread:@selector(beginShellAuth)];
    }];
    HVCHECK_NOTNULL(getTask);
    
    return;
    
LError:
    safeInvokeNotify(m_provisionCallback, self);
}

-(void)authenticationCompleted: (HealthVaultResponse *)response
{
    //
    // Ensure that we have an authorized record
    //
    if (response && response.hasError)
    {
        self.provisionStatus = HVAppProvisionFailed;
    }
    else
    {
        self.provisionStatus = HVAppProvisionSuccess;
        //
        // Capture authorized records
        //
        [self updateUser];
    }
   
    [self saveState];
    HVCLEAR(m_parentController);
    
    [self invokeOnMainThread:@selector(notifyOfProvisionStatus)]; 
}

-(void)setupInstanceInfo:(NSString *)instanceID
{
    NSUInteger index = NSNotFound;
    
    if (m_serviceDef)
    {
        index = [m_serviceDef.systemInstances.instances indexOfInstanceWithID:instanceID];
    }
    if (index == NSNotFound)
    {
        [HVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_UnknownServiceInstance)];
    }
    
    HVInstance* instance = (HVInstance *)[m_serviceDef.systemInstances.instances objectAtIndex:index];
    
    [self setEnvironment:instance];
    [self saveState];
    
    HVCLEAR(m_serviceDef);
}

-(void)notifyOfProvisionStatus
{
    safeInvokeNotify(m_provisionCallback, self);
}

-(void)subscribeAppEvents
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(didReceiveMemoryWarning)
        name:UIApplicationDidReceiveMemoryWarningNotification
        object:[UIApplication sharedApplication]
     ];
}

-(void)unsubscribeAppEvents
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
        name:UIApplicationDidReceiveMemoryWarningNotification
        object:[UIApplication sharedApplication]
    ];
}

@end
