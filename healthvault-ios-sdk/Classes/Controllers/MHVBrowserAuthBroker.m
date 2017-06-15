//
//  MHVBrowserAuthBroker.m
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

#import "MHVBrowserAuthBroker.h"
#import "NSError+MHVError.h"
#import "MHVValidator.h"

@interface MHVBrowserAuthBroker ()

@property (nonatomic, strong) MHVSignInCompletion completion;
@property (nonatomic, strong) dispatch_queue_t authQueue;
@property (nonatomic, strong) NSURL *endUrl;
@property (nonatomic, strong) NSURL *startUrl;

@property (nonatomic, strong) MHVBrowserController *browserController;

@end

@implementation MHVBrowserAuthBroker

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _authQueue = dispatch_queue_create("MHVBrowserAuthBroker.authQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)authenticateWithViewController:(UIViewController *_Nullable)viewController
                              startUrl:(NSURL *)startUrl
                                endUrl:(NSURL *)endUrl
                            completion:(MHVSignInCompletion)completion
{
    MHVASSERT_PARAMETER(startUrl);
    MHVASSERT_PARAMETER(endUrl);
    MHVASSERT_PARAMETER(completion);
    
    dispatch_async(self.authQueue, ^
                   {
                       if (!completion)
                       {
                           return;
                       }
                       
                       if (!startUrl || !endUrl)
                       {
                           completion(nil, [NSError error:[NSError MVHInvalidParameter] withDescription:@"One or more required parameters are missing."]);
                           return;
                       }
                       
                       if (self.completion)
                       {
                           completion(nil, [NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Trying to call sign in while another sign in attempt is in progress."]);
                           return;
                       }
                       
                       self.completion = completion;
                       self.startUrl = startUrl;
                       self.endUrl = endUrl;
                       
                       [self showAuthenticationControllerFromViewController:viewController];
                       
                   });
}

- (void)showAuthenticationControllerFromViewController:(UIViewController *)viewController
{
    __block UIViewController *vc = viewController;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        if (!vc)
        {
            // If no view controller parameter, default to using the root view controller.
            vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        }
        
        if (!self.browserController)
        {
            self.browserController = [[MHVBrowserController alloc] initWithAuthBroker:self];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.browserController];
        
        [vc presentViewController:navigationController animated:YES completion:nil];
    }];
}

- (void)completeWithSuccessUrl:(NSURL *)successUrl error:(NSError *)error
{
    [self.browserController dismissViewControllerAnimated:YES completion:^
     {
         dispatch_async(self.authQueue, ^
                        {
                            self.startUrl = nil;
                            self.endUrl = nil;
                            self.browserController = nil;
                            
                            if (self.completion)
                            {
                                self.completion(successUrl, error);
                                self.completion = nil;
                            }
                        });
     }];
}

- (void)userCancelled
{
    [self completeWithSuccessUrl:nil
                           error:[NSError error:[NSError MHVOperationCancelled] withDescription:@"The operation has been cancelled by the user."]];
}

#pragma mark - WKWebViewDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
{
    NSURL *url = [navigationAction.request URL];
    WKNavigationActionPolicy actionResult = WKNavigationActionPolicyAllow;
    
    if ([self didReachEndUrl:url])
    {
        [self completeWithSuccessUrl:url error:nil];
        
        actionResult = WKNavigationActionPolicyCancel;
    }

    if (decisionHandler)
    {
        decisionHandler(actionResult);
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
{
    if ([error code] == NSURLErrorCancelled)
    {
        return;
    }
    
    [self completeWithSuccessUrl:nil error:error];
}

- (BOOL)didReachEndUrl:(NSURL *)url
{
    if (!self.endUrl)
    {
        return NO;
    }
    
    NSString *urlString = [url absoluteString];
    
    NSRange authSuccess = [urlString rangeOfString:[self.endUrl absoluteString] options:NSCaseInsensitiveSearch];
    
    return (authSuccess.location != NSNotFound);
}


@end
