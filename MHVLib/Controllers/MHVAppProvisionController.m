//
//  MHVAppProvisionController.m
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

#import "MHVCommon.h"
#import "MHVAppProvisionController.h"
#import "MHVClient.h"
#import "MHVUIAlert.h"

@interface MHVAppProvisionController (HVPrivate)

-(BOOL) queryStringHasAppAuthSuccess:(NSString *) qs;
-(NSString *) instanceIDFromQs:(NSString *) qs;

@end

@implementation MHVAppProvisionController

@synthesize status = m_status;
@synthesize error = m_error;
@synthesize hvInstanceID = m_hvInstanceID;

-(BOOL)isSuccess
{
    return (m_status == HVAppProvisionSuccess);
}

-(BOOL)hasInstanceID
{
    return ![NSString isNilOrEmpty:m_hvInstanceID];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    HVCHECK_SELF;
    
    self.title = [MHVClient current].settings.signInControllerTitle;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithAppCreateUrl:(NSURL *)url andCallback:(HVNotify)callback
{
    HVCHECK_NOTNULL(url);
    HVCHECK_NOTNULL(callback);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.target = url;
    
    m_callback = [callback copy];
    HVCHECK_NOTNULL(m_callback);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    safeInvokeNotify(m_callback, self);
}

-(BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType 
{
    [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    NSLog(@"App Provisioning Current Url %@", [[request URL] absoluteString]);
    NSString* queryString = [[request URL] query];
    if ([self queryStringHasAppAuthSuccess:queryString])
    {
        m_status = HVAppProvisionSuccess;
        m_hvInstanceID = [self instanceIDFromQs:queryString];
        [self abort];
    }    

    return TRUE;
}

- (void)webView: (UIWebView *)webView didFailLoadWithError: (NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    
    if([error code] == -999)
    {
		return;   
    }
    //
    // Check if the user wants to retry...
    //
    NSString* retryMessage = [MHVClient current].settings.signinRetryMessage;
    NSString *message = [NSString stringWithFormat:@"%@\r\n%@", [error localizedDescription], retryMessage];
    
    [MHVUIAlert showWithMessage:message callback:^(id sender) {
        
        MHVUIAlert *alert = (MHVUIAlert *) sender;
        if (alert.result == HVUIAlertOK)
        {
            [self start];
        }
        else
        {
            m_status = HVAppProvisionFailed;

            m_error = error;
            
            [self abort];
        }
    }];
    
 }

@end

@implementation MHVAppProvisionController (HVPrivate)

-(BOOL)queryStringHasAppAuthSuccess:(NSString *)qs
{
    NSRange authSuccess = [qs rangeOfString:@"target=AppAuthSuccess" options:NSCaseInsensitiveSearch];
    return (authSuccess.length > 0);
}

-(NSString *)instanceIDFromQs:(NSString *)qs
{
    NSDictionary* args = [NSDictionary fromArgumentString:qs];
    if ([NSDictionary isNilOrEmpty:args])
    {
        return nil;
    }
    
    return [args objectForKey:@"instanceid"];
}

@end
