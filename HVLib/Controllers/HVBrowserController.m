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


#define RGBColor(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define HVBLUE RGBColor(0, 176, 240)

@interface HVBrowserController (HVPrivate)

-(BOOL) createBrowser;
-(BOOL) addBackButton;
-(void) backButtonClicked:(id) sender;
-(void) showActivitySpinner;
-(void) hideActivitySpinner;

@end

@implementation HVBrowserController

@synthesize target = m_target;
@synthesize webView = m_webView;

-(void)dealloc
{
    [m_target release];
    [m_webView release];
    [m_activityView release];
    
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
    [self showActivitySpinner];
 	return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivitySpinner];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivitySpinner];
}

//-----------------------
//
// Controller Stuff
//
//-----------------------

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createBrowser];    
    [self addBackButton];
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

@end

@implementation HVBrowserController (HVPrivate)

-(BOOL)createBrowser
{
    UIView* superView = super.view;
    CGRect frame = superView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    m_webView = [[UIWebView alloc] initWithFrame:frame];
    HVCHECK_NOTNULL(m_webView);
    
    m_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    m_webView.delegate = self;
    
    [superView addSubview:m_webView];  
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addBackButton
{
    self.navigationItem.hidesBackButton = TRUE;

    NSString* buttonTitle = NSLocalizedString(@"Back", @"Back button text");
    
    UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)] autorelease];
    HVCHECK_NOTNULL(button);
    
    self.navigationItem.leftBarButtonItem = button;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)showActivitySpinner
{    
    //
    // Find any existing indicators already in place
    //
    if (!m_activityView)
    {
        m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if ([m_activityView respondsToSelector:@selector(setColor:)])
        {
            [m_activityView setColor:HVBLUE];
        }
        else 
        {
            HVCLEAR(m_activityView);
            // < iOS5... use older style. The large indication won't be visible on HV pages
            m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        m_activityView.center = m_webView.center;
        m_activityView.hidesWhenStopped = TRUE;
        
        [m_webView addSubview:m_activityView];
    }
    
    [m_activityView startAnimating];
}

-(void)backButtonClicked:(id)sender
{
    if (m_webView.canGoBack)
    {
        [m_webView goBack];
    }
    else 
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

-(void)hideActivitySpinner
{
    if (m_activityView)
    {
        [m_activityView stopAnimating];
    }
}

@end
