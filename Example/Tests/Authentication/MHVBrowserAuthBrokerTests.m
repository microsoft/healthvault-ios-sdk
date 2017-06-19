//
// MHVBrowserAuthBrokerTests.m
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

#import <XCTest/XCTest.h>
#import "MHVBrowserAuthBroker.h"
#import "MHVErrorConstants.h"
#import <WebKit/WebKit.h>
#import "Kiwi.h"

#pragma mark - Helper classes

// Properties are readonly in WKNavigationAction, override request getter to return test value
@interface MHVNavigationAction : WKNavigationAction

@property (nonatomic, copy) NSURLRequest *testRequest;

@end

@implementation MHVNavigationAction

- (NSURLRequest *)request
{
    return self.testRequest;
}

@end

// Test browser controller that calls completion for dismiss
@interface MHVTestBrowserController : MHVBrowserController

@end

@implementation MHVTestBrowserController

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (completion)
    {
        completion();
    }
}

@end

// Access private property to set MHVTestBrowserController
@interface MHVBrowserAuthBroker (PrivateProperties)

@property (nonatomic, strong) MHVBrowserController *browserController;

@end


#pragma mark - Tests

SPEC_BEGIN(MHVBrowserAuthBrokerTests)

describe(@"MHVBrowserAuthBroker", ^
{
    __block MHVBrowserAuthBroker *authBroker;
    __block UIViewController *presentedViewController;
    __block void (^presentedViewControllerAction)(void);
    __block NSURL *returnedSuccessUrl;
    __block NSError *returnedError;
    __block WKNavigationActionPolicy returnedNavigationPolicy;

    WKWebView *nilWebView = nil;
    
    // Mocks for view controller
    KWMock *mockVC = [UIViewController mock];
    
    [mockVC stub:@selector(presentViewController:animated:completion:) withBlock:^id (NSArray *params)
     {
         presentedViewController = params[0];
         
         if (presentedViewControllerAction)
         {
             presentedViewControllerAction();
         }
         
         // Test framework use NSNull if a parameter is nil & completion is nullable
         if (![params[2] isKindOfClass:[NSNull class]])
         {
             void (^completion)(void) = params[2];
             completion();
         }
         
         return nil;
     }];
    
    // Clear and create new objects before each test
    beforeEach(^{
        authBroker = [[MHVBrowserAuthBroker alloc] init];
        authBroker.browserController = [[MHVTestBrowserController alloc] initWithAuthBroker:authBroker];
        
        presentedViewControllerAction = nil;
        presentedViewController = nil;
        returnedSuccessUrl = nil;
        returnedError = nil;
        returnedNavigationPolicy = -1;
    });
    
    context(@"when authenticateWithViewController is called", ^{
        beforeEach(^{
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
    });
    
    context(@"when authenticateWithViewController is called and user cancels", ^{
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                [authBroker userCancelled];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
        });
        it(@"should have a user cancelled error code", ^{
            [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(MHVErrorTypeOperationCancelled)];
        });
        it(@"should not have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
        });
    });
    
    context(@"when authenticateWithViewController is called", ^{
        context(@"with invalid argument nil start url", ^{
            beforeEach(^{
                NSURL *nilUrl = nil;
                
                presentedViewControllerAction = ^(void)
                {
                    [authBroker userCancelled];
                };
                
                [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                                  startUrl:nilUrl
                                                    endUrl:[NSURL URLWithString:@"https://end.url"]
                                                completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
                 {
                     returnedSuccessUrl = successUrl;
                     returnedError = error;
                 }];
            });
            
            it(@"should not have presented a view controller", ^{
                [[expectFutureValue(presentedViewController) shouldEventually] beNil];
            });
            it(@"should have an error", ^{
                [[expectFutureValue(returnedError) shouldEventually] beNonNil];
            });
            it(@"should have a required parameter error code", ^{
                [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
            });
            it(@"should not have a successUrl", ^{
                [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
            });
        });
        
        context(@"with invalid argument nil end url", ^{
            beforeEach(^{
                NSURL *nilUrl = nil;
                
                presentedViewControllerAction = ^(void)
                {
                    [authBroker userCancelled];
                };
                
                [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                                  startUrl:[NSURL URLWithString:@"https://start.url"]
                                                    endUrl:nilUrl
                                                completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
                 {
                     returnedSuccessUrl = successUrl;
                     returnedError = error;
                 }];
            });
            
            it(@"should not have presented a view controller", ^{
                [[expectFutureValue(presentedViewController) shouldEventually] beNil];
            });
            it(@"should have an error", ^{
                [[expectFutureValue(returnedError) shouldEventually] beNonNil];
            });
            it(@"should have a required parameter error code", ^{
                [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
            });
            it(@"should not have a successUrl", ^{
                [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
            });
        });
    });
    
    context(@"when authentication navigates to end url", ^{
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                MHVNavigationAction *navigationAction = [[MHVNavigationAction alloc] init];
                navigationAction.testRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://end.url"]];
                
                [authBroker webView:nilWebView decidePolicyForNavigationAction:navigationAction decisionHandler:^(WKNavigationActionPolicy policy)
                 {
                     returnedNavigationPolicy = policy;
                 }];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should not have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNil];
        });
        it(@"should have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNonNil];
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] equal:[NSURL URLWithString:@"https://end.url"]];
        });
        it(@"should have stopped navigating", ^{
            [[expectFutureValue(theValue(returnedNavigationPolicy)) shouldEventually] equal:theValue(WKNavigationActionPolicyCancel)];
        });
    });
    
    context(@"when authentication navigates to intermediate url", ^{
        
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                MHVNavigationAction *navigationAction = [[MHVNavigationAction alloc] init];
                navigationAction.testRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://intermediate.url"]];
                
                [authBroker webView:nilWebView decidePolicyForNavigationAction:navigationAction decisionHandler:^(WKNavigationActionPolicy policy)
                 {
                     returnedNavigationPolicy = policy;
                 }];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should not have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNil];
        });
        it(@"should not have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
        });
        it(@"should have continued web navigation", ^{
            [[expectFutureValue(theValue(returnedNavigationPolicy)) shouldEventually] equal:theValue(WKNavigationActionPolicyAllow)];
        });
    });
    
    context(@"when authenticateWithViewController is called and didFailNavigation", ^{
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                [authBroker webView:nilWebView didFailNavigation:nil withError:[NSError errorWithDomain:@"test" code:12345 userInfo:nil]];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
        });
        it(@"should have correct error values", ^{
            [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(12345)];
            [[expectFutureValue(returnedError.domain) shouldEventually] equal:@"test"];
        });
        it(@"should not have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
        });
    });

    context(@"when authenticateWithViewController is called and didFailProvisionalNavigation", ^{
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                [authBroker webView:nilWebView didFailProvisionalNavigation:nil withError:[NSError errorWithDomain:@"test" code:12345 userInfo:nil]];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
        });
        it(@"should have correct error values", ^{
            [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(12345)];
            [[expectFutureValue(returnedError.domain) shouldEventually] equal:@"test"];
        });
        it(@"should not have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
        });
    });
    
    context(@"when authenticateWithViewController is called and webViewWebContentProcessDidTerminate", ^{
        beforeEach(^{
            presentedViewControllerAction = ^(void)
            {
                [authBroker webViewWebContentProcessDidTerminate:nilWebView];
            };
            
            [authBroker authenticateWithViewController:(UIViewController *)mockVC
                                              startUrl:[NSURL URLWithString:@"https://start.url"]
                                                endUrl:[NSURL URLWithString:@"https://end.url"]
                                            completion:^(NSURL *_Nullable successUrl, NSError *_Nullable error)
             {
                 returnedSuccessUrl = successUrl;
                 returnedError = error;
             }];
        });
        
        it(@"should have presented a view controller", ^{
            [[expectFutureValue(presentedViewController) shouldEventually] beNonNil];
            [[expectFutureValue(presentedViewController) shouldEventually] beKindOfClass:[UIViewController class]];
        });
        it(@"should have an error", ^{
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
        });
        it(@"should have correct error values", ^{
            [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:theValue(MHVErrorTypeOperationCancelled)];
        });
        it(@"should not have a successUrl", ^{
            [[expectFutureValue(returnedSuccessUrl) shouldEventually] beNil];
        });
    });
});

SPEC_END
