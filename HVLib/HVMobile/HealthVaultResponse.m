//
//  HealthVaultResponse.m
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


#import "HealthVaultResponse.h"
#import "XmlTextReader.h"
#import "XmlElement.h"

@interface HealthVaultResponse (Private)

/// Initializes the fields using xml string provided.
/// @param xml - response xml representation.
- (BOOL)parseFromXml: (NSString *)xml;

/// Retrieves info section from xml.
/// Info section is represented by <wc:info> xml element.
/// @param xml - xml from which to retrieve info section.
/// @returns info section in provided xml
- (NSString *)getInfoFromXml: (NSString *)xml;

@end

@implementation HealthVaultResponse

@synthesize statusCode = _statusCode;
@synthesize webStatusCode = _webStatusCode;
@synthesize infoXml = _infoXml;
@synthesize responseXml = _responseXml;
@synthesize errorText = _errorText;
@synthesize errorContextXml = _errorContextXml;
@synthesize errorInfo = _errorInfo;
@synthesize request = _request;

- (id)initWithWebResponse: (WebResponse *)webResponse
				  request: (HealthVaultRequest *)request {

	if ((self = [super init])) {

		NSString *xml = webResponse.responseData;
		
		self.request = request;
		self.responseXml = xml;
		self.webStatusCode = webResponse.webStatusCode;
        
		if(webResponse.hasError) {
			
			self.errorText = webResponse.errorText;
		}
		else {
			
			BOOL xmlReaderesult = [self parseFromXml: xml];

			if (!xmlReaderesult) {
				self.errorText = [NSString stringWithFormat: NSLocalizedString(@"Response was not a valid HealthVault response key",
																			   @"Format to display incorrect response"), xml];
			}
		}
	}

	return self;
}

- (void)dealloc {

	self.errorText = nil;
	self.errorContextXml = nil;
	self.errorInfo = nil;
	self.request = nil;
	self.infoXml = nil;
	self.responseXml = nil;

	[super dealloc];
}

- (BOOL)getHasError {

	return self.errorText != nil;
}

- (BOOL)parseFromXml: (NSString *)xml {

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	@try {

		XmlTextReader *xmlReader = [[XmlTextReader new] autorelease];
		XmlElement *root = [xmlReader read: xml];

		if (!root) {
			return NO;
		}

		// Parse status
		XmlElement *statusNode = [root selectSingleNode: @"status"];
		if (statusNode) {
			self.statusCode = [[statusNode selectSingleNode: @"code"].text intValue];
		}

		// Parse message
		XmlElement *errorNode = [statusNode selectSingleNode: @"error"];
		if (errorNode) {

			self.errorText = [errorNode selectSingleNode: @"message"].text;
			self.errorContextXml = [errorNode selectSingleNode: @"context"].text;
			self.errorInfo = [errorNode selectSingleNode: @"error-info"].text;
		}

		self.infoXml = [self getInfoFromXml: xml];
	}
	@catch (id exc) {

		return NO;
	}
	@finally {

		[pool release];
	}

	return YES;
}

- (NSString *)getInfoFromXml: (NSString *)xml {

	NSRange startInfoTagPosition = [xml rangeOfString: @"<wc:info"];
	NSRange endInfoTagPosition = [xml rangeOfString: @"</wc:info>" options:NSBackwardsSearch];
	
	if (startInfoTagPosition.location == NSNotFound || endInfoTagPosition.location == NSNotFound) {
		return nil;
	}

	NSRange infoTagRange;
	infoTagRange.location = startInfoTagPosition.location;
	infoTagRange.length = endInfoTagPosition.location + endInfoTagPosition.length - startInfoTagPosition.location;

	NSString *info = [xml substringWithRange: infoTagRange];

	return info;
}

@end
