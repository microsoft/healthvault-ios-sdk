//
// MHVNetworkObserver.m
// healthvault-ios-sdk
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

#import "MHVNetworkObserver.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <CoreFoundation/CoreFoundation.h>

static void ObserverCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [MHVNetworkObserver class]], @"info was wrong class in ObserverCallback");
    
    MHVNetworkObserver *observer = (__bridge MHVNetworkObserver *)info;
    [observer currentNetworkStatus];
}

@implementation MHVNetworkObserver
{
	SCNetworkReachabilityRef _reachabilityRef;
}

@synthesize status = _status;

#pragma mark - Public

+ (instancetype)observerWithHostName:(NSString *)hostName
{
	MHVNetworkObserver *observer;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL)
	{
		observer = [[self alloc] init];
		if (observer != NULL)
		{
			observer->_reachabilityRef = reachability;
            [observer startNotifier];
		}
        else
        {
            CFRelease(reachability);
        }
	}
	return observer;
}

- (MHVNetworkStatus)currentNetworkStatus
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    MHVNetworkStatus status = MHVNetworkStatusNoNetwork;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        status = [self networkStatusForFlags:flags];
    }
    
    if (_status != status)
    {
        _status = status;
    }
    
    return status;
}

#pragma mark - Private

- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ObserverCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (void)stopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc
{
    [self stopNotifier];
    
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}

- (MHVNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// The target host is not reachable.
		return MHVNetworkStatusNoNetwork;
	}

    MHVNetworkStatus returnValue = MHVNetworkStatusNoNetwork;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = MHVNetworkStatusWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = MHVNetworkStatusWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = MHVNetworkStatusWWAN;
	}
    
	return returnValue;
}

@end
