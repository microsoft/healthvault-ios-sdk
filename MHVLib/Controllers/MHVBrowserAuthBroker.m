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

typedef void (^MHVSignInCompletion)(NSURL *_Nullable successUrl, NSError *_Nullable error);

@interface MHVBrowserAuthBroker ()

@property (nonatomic, strong) MHVSignInCompletion completion;
@property (nonatomic, strong) dispatch_queue_t authQueue;
@property (nonatomic, strong) NSURL *endUrl;

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
                            completion:(void (^)(NSURL *_Nullable successUrl, NSError *_Nullable error))completion
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
                       }
                       
                       if (self.completion)
                       {
                           completion(nil, [NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Trying to call sign in while another sign in attempt is in progress."]);
                       }
                       
                       self.completion = completion;
                       self.target = startUrl;
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
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        
        [vc presentViewController:navigationController animated:YES completion:nil];
    }];
}

- (void)completeWithSuccessUrl:(NSURL *)successUrl error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         dispatch_async(self.authQueue, ^
                        {
                            self.target = nil;
                            self.endUrl = nil;
                            self.completion(successUrl, error);
                            self.completion = nil;
                        });
     }];
}

#pragma mark - Overrides

- (void)viewWillDisappear: (BOOL)animated
{
    // Overriding default behavior of MHVBrowserController
    [super viewWillDisappear:animated];
}

- (void)abort
{
    // Overriding default behavior of MHVBrowserController
}

- (void)cancelButtonPressed:(id)sender
{
    [self completeWithSuccessUrl:nil error:[NSError error:[NSError MHVOperationCancelled] withDescription:@"The operation has been cancelled by the user."]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    NSLog(@"App Provisioning Current Url %@", [[request URL] absoluteString]);
    
    NSURL* url = [request URL];
    
    if ([self didReachEndUrl:url])
    {        
        [self completeWithSuccessUrl:url error:nil];
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    
    if([error code] == -999)
    {
        return;   
    }
    
    [self completeWithSuccessUrl:nil error:error];
    
}

- (BOOL)didReachEndUrl:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    
    NSRange authSuccess = [urlString rangeOfString:[self.endUrl absoluteString] options:NSCaseInsensitiveSearch];
    
    return (authSuccess.length > 0);
}


@end
