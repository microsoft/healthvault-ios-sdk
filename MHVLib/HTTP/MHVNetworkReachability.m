//
//  MHVNetworkReachability.m
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

#import "MHVCommon.h"
#import "MHVNetworkReachability.h"

HVDEFINE_NOTIFICATION(HVHostReachabilityNotificationName);

BOOL HVIsHostNetworkReachable(NSString* hostName)
{
    HVCHECK_NOTNULL(hostName);
    
    const char* szHostName = [hostName cStringUsingEncoding:NSUTF8StringEncoding]; // buffer is owned by NSString
    HVCHECK_NOTNULL(szHostName);
    
    SCNetworkReachabilityRef hostRef = SCNetworkReachabilityCreateWithName(NULL, szHostName);
    SCNetworkReachabilityFlags networkFlags;
    
    BOOL result = SCNetworkReachabilityGetFlags(hostRef, &networkFlags);
    CFRelease(hostRef);
    
    HVCHECK_TRUE(result);
    
    return ((networkFlags & kSCNetworkFlagsReachable) != 0 &&
            (networkFlags & kSCNetworkFlagsConnectionRequired) == 0
            );
    
LError:
    return FALSE;
}

static void HostReachabilityStatusChanged(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    @try
    {
        if (info)
        {
            MHVHostReachability* host = (__bridge MHVHostReachability *) info;
            [host broadcastStatusChange:flags];
        }
    }
    @catch (NSException *exception)
    {
        [exception log];
    }
}

@interface MHVHostReachability (HVPrivate)

-(BOOL) enableNotifications:(BOOL) enable;
-(BOOL) enableCallback:(BOOL) enable;

@end

@implementation MHVHostReachability

@synthesize hostName = m_hostName;
@synthesize status = m_status;
-(BOOL)isReachable
{
    return ((m_status & kSCNetworkFlagsReachable) != 0 &&
            (m_status & kSCNetworkFlagsConnectionRequired) == 0
            );
}
@synthesize isMonitoring = m_isMonitoring;

-(id)initWithUrl:(NSURL *)url
{
    return [self initWithHostName:url.host];
}

-(id)initWithHostName:(NSString *)hostName
{
    HVCHECK_STRING(hostName);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_hostName = hostName;

    const char* szHostName = [hostName cStringUsingEncoding:NSUTF8StringEncoding]; // buffer is owned by NSString
    HVCHECK_NOTNULL(szHostName);
    
    m_hostRef = SCNetworkReachabilityCreateWithName(NULL, szHostName);
    HVCHECK_NOTNULL(m_hostRef);
    
    m_status = kSCNetworkFlagsReachable; // Assume the best
    m_isMonitoring = FALSE;
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [self stopMonitoring];
    
    if (m_hostRef)
    {
        CFRelease(m_hostRef);
    }
    
}

-(BOOL)refreshStatus
{
    SCNetworkReachabilityFlags status = 0;
    if (!SCNetworkReachabilityGetFlags(m_hostRef, &status))
    {
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)startMonitoring
{
    if (m_isMonitoring)
    {
        return TRUE;
    }
    
    [self refreshStatus];
    
    HVCHECK_SUCCESS([self enableCallback:TRUE]);
    HVCHECK_SUCCESS([self enableNotifications:TRUE]);
    
    m_isMonitoring = TRUE;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)stopMonitoring
{
    if (!m_isMonitoring)
    {
        return TRUE;
    }
    
    HVCHECK_SUCCESS([self enableNotifications:FALSE]);
    HVCHECK_SUCCESS([self enableCallback:FALSE]);
    
    m_isMonitoring = FALSE;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)broadcastStatusChange:(SCNetworkConnectionFlags)flags
{
    BOOL shouldNotify = FALSE;
    @synchronized(self)
    {
        shouldNotify = (flags != 0 && m_status != flags);
        m_status = flags;
    }
    if (shouldNotify)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName: HVHostReachabilityNotificationName
         object:self
         ];
    }
}

-(void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector
{
    [[NSNotificationCenter defaultCenter]
     addObserver:notificationObserver
     selector:notificationSelector
     name:HVHostReachabilityNotificationName
     object:self];
}

-(void)removeObserver:(id)notificationObserver
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:notificationObserver
     name:HVHostReachabilityNotificationName
     object:self];
}

@end

@implementation MHVHostReachability (HVPrivate)

-(BOOL)enableCallback:(BOOL)enable
{
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    return (SCNetworkReachabilitySetCallback(m_hostRef, (enable) ? HostReachabilityStatusChanged : NULL, &context));
}

-(BOOL)enableNotifications:(BOOL)enable
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    if (enable)
    {
        return SCNetworkReachabilityScheduleWithRunLoop(m_hostRef, runLoop, kCFRunLoopDefaultMode);
    }
    
    return SCNetworkReachabilityUnscheduleFromRunLoop(m_hostRef, runLoop, kCFRunLoopDefaultMode);

}

@end
