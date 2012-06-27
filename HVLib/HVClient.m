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

static HVClient* s_app;

@interface HVClient (HVPrivate)

-(BOOL) ensureLocalVault;

-(HealthVaultService *) newService;
-(void) updateUser;
-(HVUser *) loadUser;
-(void) setUser:(HVUser *) user;
-(BOOL) saveUser;
-(void) deleteUser;

//
// Callbacks from HealthVaultService
//
-(void) beginAuth;
-(void)shellAuthRequired: (HealthVaultResponse *)response;
-(void) beginShellAuth;
-(void)authenticationCompleted: (HealthVaultResponse *)response;
-(void) notifyOfProvisionStatus;

@end


@implementation HVClient

@synthesize settings = m_settings;
@synthesize localVault = m_localVault;
@synthesize rootDirectory = m_rootDirectory;
@synthesize provisionStatus = m_provisionStatus;
@synthesize service = m_service;
@synthesize user = m_user;

+(void)initialize
{
    s_app = [[HVClient alloc] init];
}

+(HVClient *)current
{
    return s_app;
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
    return (![NSString isNilOrEmpty:m_service.sessionSharedSecret] && m_user && m_user.hasRecords);
}

-(HVRecordCollection *)records
{
    return (m_user) ? m_user.records : nil;
}

-(HVRecord *)currentRecord
{
    return (m_user) ? m_user.currentRecord : nil;
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_queue = [[NSOperationQueue alloc] init];
    HVCHECK_NOTNULL(m_queue);
    
    m_settings = [HVClientSettings newSettingsFromResource];
    HVCHECK_NOTNULL(m_settings);
    
    HVCHECK_SUCCESS([self ensureLocalVault]);
    
    // Set up the HealthVault Service
    m_service = [self newService];
    HVCHECK_NOTNULL(m_service);
    
    [self loadState];
    
    if (m_user.hasRecords)
    {
        m_provisionStatus = HVAppProvisionSuccess;
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_queue release];
    [m_settings release];
    [m_rootDirectory release];
    [m_service release];
    
    [m_parentController release];
    [m_provisionCallback release];
    
    [m_localVault release];
    [m_user release];
    
    [super dealloc];
}

-(BOOL)startWithParentController:(UIViewController *)controller andStartedCallback:(HVNotify)callback
{
    @synchronized(self)
    {
        HVCHECK_NOTNULL(controller);
        HVCHECK_NOTNULL(callback);
        
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
        
        NSString* userEnvironment = self.user.environment;
        if (![NSString isNilOrEmpty:userEnvironment])
        {
            HVEnvironmentSettings* environment = [m_settings environmentWithName:userEnvironment];
            if (environment)
            {
                [m_service applyEnvironmentSettings:environment];
            }
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
        return [self saveUser];
    }
}

-(BOOL)deleteState
{
    @synchronized(self)
    {
        [self deleteUser];
        return TRUE;
    }
}

-(BOOL)resetProvisioning
{
    @synchronized(self)
    {
        self.provisionStatus = HVAppProvisionCancelled;
        
        if (m_service)
        {
            [m_service reset];
            [m_service saveSettings];
        }
        //
        // Delete local state
        //
        [self deleteUser];
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

-(HVLocalRecordStore *)getCurrentRecordStore
{
    return [m_localVault getRecordStore:self.currentRecord];
}

@end

static NSString* const c_userfileName = @"user.xml";

@implementation HVClient (HVPrivate)

-(BOOL)ensureLocalVault
{
    if (!m_rootDirectory)
    {
        m_rootDirectory = [[HVDirectory alloc] initWithRelativePath:@"HealthVault"];
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

-(HealthVaultService *)newService
{
    HVEnvironmentSettings* environment = [m_settings firstEnvironment];
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
    [self invokeOnMainThread:@selector(beginShellAuth)];
}

-(void)beginAuth
{
    [m_service performAuthenticationCheck:self authenticationCompleted:@selector(authenticationCompleted:) shellAuthRequired:@selector(shellAuthRequired:)];    
}

-(void)beginShellAuth
{
    [self saveState];
    
    self.provisionStatus = HVAppProvisionCancelled;

    NSURL* creationUrl = [NSURL URLWithString:[m_service getApplicationCreationUrl]];
    HVCHECK_NOTNULL(creationUrl);
    
   HVAppProvisionController * shellController = [[HVAppProvisionController alloc] initWithAppCreateUrl:creationUrl andCallback:^(HVAppProvisionController *controller) {
        
        if (controller.status == HVAppProvisionSuccess)
        {
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

-(void)notifyOfProvisionStatus
{
    safeInvokeNotify(m_provisionCallback, self);
}

@end
