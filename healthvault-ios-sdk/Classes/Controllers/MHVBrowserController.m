//
//  MHVBrowserController.m
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
#import "MHVBrowserController.h"
#import <QuartzCore/QuartzCore.h>

#define RGBColor(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define MHVBLUE RGBColor(0, 176, 240)

@interface MHVBrowserController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation MHVBrowserController

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)start
{
    if (self.target)
    {
        return [self navigateTo:self.target];
    }
    
    [self abort];
    
    return NO;
}

- (BOOL)stop
{
    if (self.webView)
    {
        [self.webView stopLoading];
    }
    
    return YES;
}

- (BOOL)navigateTo:(NSURL *)url
{
    MHVASSERT_PARAMETER(url);
    
    if (!url)
    {
        return NO;
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];
    
    return YES;
}

- (void)abort
{
    [self stop];
    [self.navigationController popViewControllerAnimated:TRUE];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self showActivitySpinner];
 	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivitySpinner];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivitySpinner];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createBrowser];    
    [self addCancelButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self start];
}

- (void)viewWillDisappear: (BOOL)animated 
{
    [self stop];
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return FALSE;
            
        default:
            break;
    }
    
    return TRUE;
}

- (void)createBrowser
{
    UIView* superView = super.view;
    CGRect frame = superView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    
    [superView addSubview:self.webView];
}

- (void)addCancelButton
{
    self.navigationItem.hidesBackButton = TRUE;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)showActivitySpinner
{    
    //
    // Find any existing indicators already in place
    //
    if (!self.activityView)
    {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityView setColor:MHVBLUE];
        self.activityView.center = self.webView.center;
        self.activityView.hidesWhenStopped = TRUE;
        
        [self.webView addSubview:self.activityView];
    }
    
    [self.activityView startAnimating];
}

- (void)cancelButtonPressed:(id)sender
{
    if (self.webView.canGoBack)
    {
        [self.webView goBack];
    }
    else 
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (void)hideActivitySpinner
{
    if (self.activityView)
    {
        [self.activityView stopAnimating];
    }
}

@end
