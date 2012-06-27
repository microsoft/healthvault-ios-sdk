//
//  WebTransport.m
//  HealthVault Mobile Library for iOS
//
// Copyright 2011 Microsoft Corp.
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

#import "WebTransport.h"
#import "WebResponse.h"
#import "Logger.h"
#import "HealthVaultConfig.h"
#import "HVClient.h"

/// Default HTTP method.
#define DEFAULT_HTTP_METHOD @"POST"

/// Default timeout time for request.
/// Apple-recommended value for such operations.
#define DEFAULT_REQUEST_TIMEOUT 240

@interface WebTransport (Private)

/// Logs message, prints it to console.
/// @param message - message to be written.
+ (void)addMessageToRequestResponseLog: (NSString *)message;

/// Sends a post request to a specific URL.
/// @param url - string which contains server address.
/// @param data - string will be sent in POST header.
/// @param context - any object will be passed to callBack with response.
/// @param target - callback method owner.
/// @param callBack - the method to call when the request has completed.
- (NSURLConnection *)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack;

/// Performs callBack on target when response is received.
/// @param response - response to send.
- (void)performCallBack: (WebResponse *)response;

@end


@implementation WebTransport

/// Represents logging status (enabled/disabled).
static BOOL _isRequestResponseLogEnabled = HEALTH_VAULT_TRACE_ENABLED;

- (void)dealloc {

    [_response release];
    [_responseBody release];
    [_context release];
    [_target release];
    [_connection release];
    
    [super dealloc];
}

#pragma mark Static Messages

+ (BOOL)isRequestResponseLogEnabled {

    return _isRequestResponseLogEnabled;
}

+ (void)setRequestResponseLogEnabled: (BOOL)enabled {

    @synchronized (self) {

        _isRequestResponseLogEnabled = enabled;
    }
}

+ (void)addMessageToRequestResponseLog: (NSString *)message {

    if (!_isRequestResponseLogEnabled) {
        return;
    }

    [Logger write: [NSString stringWithFormat: NSLocalizedString(@"HealthVault web transport message key",
																 @"Format to display web transport message"), message]];
}

#pragma mark Static Messages End

+ (NSURLConnection *)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack {

    WebTransport *transport = [[WebTransport new] autorelease];
    return [transport sendRequestForURL: url
            withData: data
            context: context
            target: target
            callBack: callBack];
}

- (NSURLConnection *)sendRequestForURL: (NSString *)url
                 withData: (NSString *)data
                  context: (NSObject *)context
                   target: (NSObject *)target
                 callBack: (SEL)callBack {

    _target = [target retain];
    _callBack = callBack;
    _context = [context retain];
    _responseBody = [[NSMutableData data] retain];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
	
/*
#ifdef CONNECTION_ALLOW_ANY_HTTPS_CERTIFICATE
	// required for unit tests, see http://www.openradar.me/8385355
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString: url] host]];
	// alternative way is handling canAuthenticateAgainstProtectionSpace challannge
	// http://stackoverflow.com/questions/933331/
#endif
*/	
    [request setTimeoutInterval: [HVClient current].settings.httpTimeout];

    if (data) {
        [WebTransport addMessageToRequestResponseLog: data];

        NSData *xmlData = [data dataUsingEncoding: NSUTF8StringEncoding];

        [request setHTTPMethod: DEFAULT_HTTP_METHOD];
        [request addValue: [NSString stringWithFormat: @"%d", xmlData.length] forHTTPHeaderField: @"Content-Length"];
        [request setHTTPBody: xmlData];
    }

    _connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
    [_connection start];
    
    return _connection;
}

#pragma mark Connection Events

- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {

    [_response release];
    _response = [response retain];
    
    if (_responseBody) {
        [_responseBody setLength: 0];
    }
}

- (void)connection: (NSURLConnection *)conn didReceiveData: (NSData *)data {

    if (_responseBody && data) {
        [_responseBody appendData: data];
    }
}

- (void)connectionDidFinishLoading: (NSURLConnection *)conn {

    WebResponse *response = [WebResponse new];
    NSString* responseString = nil;
    @try 
    {
        response.webStatusCode = [((NSHTTPURLResponse *)_response) statusCode];
        if (response.webStatusCode >= 400)
        {       
            response.errorText = [NSHTTPURLResponse localizedStringForStatusCode:response.webStatusCode];
        }
        else 
        {
            responseString = [[NSString alloc] initWithData: _responseBody encoding: NSUTF8StringEncoding];
            [WebTransport addMessageToRequestResponseLog: responseString];
            
            response.responseData = responseString;
        }
        
        [self performCallBack: response];
    }
    @catch (id exception) 
    {
    }
    
    [response release];
    [responseString release];
}

- (void)connection: (NSURLConnection *)conn didFailWithError: (NSError *)error {

    NSString *errorString = [error localizedDescription];

    TraceComponentError(@"WebTransport", NSLocalizedString(@"Connection error key",
														   @"Format to display connection error"), errorString);

    [WebTransport addMessageToRequestResponseLog: errorString];
    
    WebResponse *response = [WebResponse new];
    @try 
    {
        response.errorText = errorString;
        if (_response)
        {
            response.webStatusCode = [((NSHTTPURLResponse *)_response) statusCode];
        }
        [self performCallBack: response];
    }
    @catch (id exception) 
    {
    }
    
    [response release];
}

#pragma mark Connection Events End

- (void)performCallBack: (WebResponse *)response {

    if (_target && [_target respondsToSelector: _callBack]) {

        [_target performSelector: _callBack withObject: response withObject: _context];
    }
}

@end
