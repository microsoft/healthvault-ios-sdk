//
//  HVBrowserController.m
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
#import "HVBrowserController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HVBrowserController

@synthesize target = m_target;
@synthesize webView = m_webView;

-(void)dealloc
{
    [m_target release];
    [m_webView release];
    
    [super dealloc];
}

-(BOOL)start
{
    if (m_target)
    {
        return [self navigateTo:m_target];
    }
    
    [self abort];
    
    return FALSE;
}

-(BOOL)stop
{
    [m_webView stopLoading];
    return TRUE;
}

-(BOOL)navigateTo:(NSURL *)url
{
    HVCHECK_NOTNULL(url);
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    HVCHECK_NOTNULL(request);
    
    [m_webView loadRequest:request];
    [request release];
    
    return TRUE;
    
LError:
    return false;
}

-(void)abort
{
    [self stop];
    [self.navigationController popViewControllerAnimated:TRUE];
}

//-----------------------
//
// WebView Delegate
//
//-----------------------
-(BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request
 navigationType: (UIWebViewNavigationType)navigationType 
{
 	return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

//-----------------------
//
// Controller Stuff
//
//-----------------------

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* superView = super.view;
    CGRect frame = superView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    m_webView = [[UIWebView alloc] initWithFrame:frame];
    m_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    m_webView.delegate = self;
    
    [superView addSubview:m_webView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self start];
}

- (void)viewWillDisappear: (BOOL)animated 
{
    [self stop];
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
