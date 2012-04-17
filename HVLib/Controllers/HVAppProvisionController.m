//
//  HVAppProvisionController.m
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
#import "HVAppProvisionController.h"
#import "HVClient.h"
#import "HVUIAlert.h"

@implementation HVAppProvisionController

@synthesize status = m_status;
@synthesize error = m_error;

-(BOOL)isSuccess
{
    return (m_status == HVAppProvisionSuccess);
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

-(void)dealloc
{
    [m_error release];
    [m_callback release];
    
    [super dealloc];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    safeInvokeNotify(m_callback, self);
}

-(BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request
navigationType: (UIWebViewNavigationType)navigationType 
{
    NSString* queryString = [[request URL] query];
    NSRange authSuccess = [queryString rangeOfString:@"target=AppAuthSuccess"];
    
    if (authSuccess.length > 0)
    {
        m_status = HVAppProvisionSuccess;
        [self abort];
    }
    
    return TRUE;
}

- (void)webView: (UIWebView *)webView didFailLoadWithError: (NSError *)error
{
    if([error code] == -999)
    {
		return;   
    }
    //
    // Check if the user wants to retry...
    //
    NSString *message = [NSString stringWithFormat:@"%@\r\n%@", [error localizedDescription], NSLocalizedString(@"Retry sign in?", @"Soda auth retry?")];
    
    [HVUIAlert showWithMessage:message callback:^(id sender) {
        
        HVUIAlert *alert = (HVUIAlert *) sender;
        if (alert.result == HVUIAlertOK)
        {
            [self start];
        }
        else
        {
            m_status = HVAppProvisionFailed;

            HVRETAIN(m_error, error);
            
            [self abort];
        }
    }];
    
 }


@end
