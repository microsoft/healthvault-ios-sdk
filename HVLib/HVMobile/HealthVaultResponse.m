//
//  HealthVaultResponse.m
//  HealthVault Mobile Library for iOS
//
// Copyright 2017 Microsoft Corp.
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
#import "HealthVaultResponse.h"
#import "XmlTextReader.h"
#import "XmlElement.h"
#import "HVResponse.h"

@interface HealthVaultResponse (Private)

-(BOOL) deserializeXml:(NSString *) xml;

/// Initializes the fields using xml string provided.
/// @param xml - response xml representation.
- (BOOL)parseFromXml: (NSString *)xml __deprecated; // Use deserializeXml instead

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
			//BOOL xmlReaderesult = [self parseFromXml: xml]; // Old mechanism.. replaced by much faster new serializer
            BOOL xmlReaderesult = [self deserializeXml:xml];

			if (!xmlReaderesult) {
				self.errorText = [NSString stringWithFormat: NSLocalizedString(@"Response was not a valid HealthVault response key",
																			   @"Format to display incorrect response"), xml];
			}
		}
	}

	return self;
}


- (BOOL)getHasError {

	return self.errorText != nil;
}

-(BOOL)deserializeXml:(NSString *)xml
{
    HVResponse* response = nil;
	@try
    {
        response = (HVResponse *)[NSObject newFromString:xml withRoot:@"response" asClass:[HVResponse class]];
		if (!response)
        {
			return FALSE;
		}
        
        HVResponseStatus* status = response.status;
        if (status)
        {
            self.statusCode = status.code;
            HVServerError* error = status.error;
            if (status.error)
            {
                self.errorText = error.message;
                self.errorContextXml = error.context;
                self.errorInfo = error.errorInfo;
            }
        }
        
		self.infoXml = response.body;
        
        return TRUE;
	}
	@catch (id ex)
    {
        [ex log];
	}
	@finally {
        
		response = nil;
	}
    
	return FALSE;
    
}

//
// DEPRECATED
//
- (BOOL)parseFromXml: (NSString *)xml {

    @autoreleasepool
    {
        @try {
            
            XmlTextReader *xmlReader = [XmlTextReader new];
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
