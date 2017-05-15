//
// MHVNetworkReachability.m
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
//

#import "MHVCommon.h"
#import "MHVNetworkReachability.h"

MHVDEFINE_NOTIFICATION(MHVHostReachabilityNotificationName);

BOOL MHVIsHostNetworkReachable(NSString *hostName)
{
    MHVCHECK_NOTNULL(hostName);

    const char *szHostName = [hostName cStringUsingEncoding:NSUTF8StringEncoding]; // buffer is owned by NSString
    MHVCHECK_NOTNULL(szHostName);

    SCNetworkReachabilityRef hostRef = SCNetworkReachabilityCreateWithName(NULL, szHostName);
    SCNetworkReachabilityFlags networkFlags;

    BOOL result = SCNetworkReachabilityGetFlags(hostRef, &networkFlags);
    CFRelease(hostRef);

    MHVCHECK_TRUE(result);

    return (networkFlags & kSCNetworkFlagsReachable) != 0 &&
           (networkFlags & kSCNetworkFlagsConnectionRequired) == 0;
}

static void HostReachabilityStatusChanged(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    @try
    {
        if (info)
        {
            MHVHostReachability *host = (__bridge MHVHostReachability *)info;
            [host broadcastStatusChange:flags];
        }
    }
    @catch (NSException *exception)
    {
        [exception log];
    }
}

@interface MHVHostReachability ()

@property (readwrite, nonatomic, strong) NSString *hostName;
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef hostRef;
@property (readwrite, nonatomic, assign) SCNetworkReachabilityFlags status;
@property (readwrite, nonatomic, assign) BOOL isReachable;

@end

@implementation MHVHostReachability

- (BOOL)isReachable
{
    return (self.status & kSCNetworkFlagsReachable) != 0 &&
           (self.status & kSCNetworkFlagsConnectionRequired) == 0;
}

- (instancetype)initWithUrl:(NSURL *)url
{
    return [self initWithHostName:url.host];
}

- (instancetype)initWithHostName:(NSString *)hostName
{
    MHVCHECK_STRING(hostName);

    self = [super init];
    if (self)
    {
        _hostName = hostName;

        const char *szHostName = [hostName cStringUsingEncoding:NSUTF8StringEncoding]; // buffer is owned by NSString
        MHVCHECK_NOTNULL(szHostName);

        _hostRef = SCNetworkReachabilityCreateWithName(NULL, szHostName);
        MHVCHECK_NOTNULL(_hostRef);

        _status = kSCNetworkFlagsReachable; // Assume the best
        _isMonitoring = FALSE;
    }

    return self;
}

- (void)dealloc
{
    [self stopMonitoring];

    if (self.hostRef)
    {
        CFRelease(self.hostRef);
    }
}

- (BOOL)refreshStatus
{
    SCNetworkReachabilityFlags status = 0;

    if (!SCNetworkReachabilityGetFlags(self.hostRef, &status))
    {
        return FALSE;
    }

    return TRUE;
}

- (BOOL)startMonitoring
{
    if (self.isMonitoring)
    {
        return TRUE;
    }

    [self refreshStatus];

    MHVCHECK_SUCCESS([self enableCallback:TRUE]);
    MHVCHECK_SUCCESS([self enableNotifications:TRUE]);

    self.isMonitoring = TRUE;

    return TRUE;
}

- (BOOL)stopMonitoring
{
    if (!self.isMonitoring)
    {
        return TRUE;
    }

    MHVCHECK_SUCCESS([self enableNotifications:FALSE]);
    MHVCHECK_SUCCESS([self enableCallback:FALSE]);

    self.isMonitoring = FALSE;

    return TRUE;
}

- (void)broadcastStatusChange:(SCNetworkConnectionFlags)flags
{
    BOOL shouldNotify = FALSE;

    @synchronized(self)
    {
        shouldNotify = (flags != 0 && self.status != flags);
        self.status = flags;
    }
    if (shouldNotify)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:MHVHostReachabilityNotificationName
         object:self
        ];
    }
}

- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector
{
    [[NSNotificationCenter defaultCenter]
     addObserver:notificationObserver
     selector:notificationSelector
     name:MHVHostReachabilityNotificationName
     object:self];
}

- (void)removeObserver:(id)notificationObserver
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:notificationObserver
     name:MHVHostReachabilityNotificationName
     object:self];
}

#pragma mark - Internal methods

- (BOOL)enableCallback:(BOOL)enable
{
    SCNetworkReachabilityContext context = {
        0, (__bridge void *)(self), NULL, NULL, NULL
    };

    return SCNetworkReachabilitySetCallback(self.hostRef, (enable) ? HostReachabilityStatusChanged : NULL, &context);
}

- (BOOL)enableNotifications:(BOOL)enable
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];

    if (enable)
    {
        return SCNetworkReachabilityScheduleWithRunLoop(self.hostRef, runLoop, kCFRunLoopDefaultMode);
    }

    return SCNetworkReachabilityUnscheduleFromRunLoop(self.hostRef, runLoop, kCFRunLoopDefaultMode);
}

@end
