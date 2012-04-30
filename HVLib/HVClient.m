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
    
    m_rootDirectory = [[HVDirectory alloc] initWithRelativePath:@"HealthVault"];
    HVCHECK_NOTNULL(m_rootDirectory);
    
    m_localVault = [[HVLocalVault alloc] initWithRoot:m_rootDirectory];
    
    // Set up the HealthVault Service (for now)
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
    HVCHECK_NOTNULL(controller);
    HVCHECK_NOTNULL(callback);
    
    HVRETAIN(m_parentController, controller);
    HVCLEAR(m_provisionCallback);
    
    m_provisionCallback = [callback copy];
    
    [self loadState];
    
    if (self.isProvisioned)
    {
        // Already provisioned. 
        m_provisionStatus = HVAppProvisionSuccess;
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

-(void)queueOperation:(NSOperation *)op
{
    [m_queue addOperation:op];
}

-(BOOL)loadState
{
    if (m_service)
    {
        [m_service loadSettings:@"HVClient"];
    }
    
    HVCLEAR(m_user);
    self.user = [self loadUser]; // ok if this is null
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)saveState
{
    if (m_service)
    {
        [m_service saveSettings:@"HVClient"];
    }
    
    return [self saveUser];
}

-(BOOL)deleteState
{
    [self deleteUser];
    return TRUE;
}

@end

static NSString* const c_userfileName = @"user.xml";

@implementation HVClient (HVPrivate)

-(void)updateUser
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

-(HVUser *)loadUser
{
    HVUser *user = [m_localVault.root getObjectWithKey:c_userfileName name:@"user" andClass:[HVUser class]];
    if (user && [user validate].isError)
    {
        [self deleteUser];
        user = nil;
    }
    
    return user;
}

-(void)setUser:(HVUser *)user
{
    HVRETAIN(m_user, user);
}

-(BOOL)saveUser
{
    if (!m_user)
    {
        return TRUE;
    }
    
    return [m_localVault.root putObject:m_user withKey:c_userfileName andName:@"user"];
}

-(void)deleteUser
{
    [m_localVault.root deleteKey:c_userfileName];
    self.user = nil;
}

-(HealthVaultService *)newService
{
    HealthVaultService *service =  [[HealthVaultService alloc] 
                                    initWithUrl:m_settings.serviceUrl.absoluteString 
                                    shellUrl:m_settings.shellUrl.absoluteString 
                                    masterAppId:m_settings.masterAppID];
    
    HVCHECK_NOTNULL(service);
    
    service.country = m_settings.country;
    service.language = m_settings.language;
    service.deviceName = m_settings.deviceName;
    
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
    
    m_provisionStatus = HVAppProvisionCancelled;

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
        m_provisionStatus = HVAppProvisionFailed;
    }
    else
    {
        m_provisionStatus = HVAppProvisionSuccess;
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
