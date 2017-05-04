//
//  HealthVaultRecord.m
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

#import "HealthVaultRecord.h"
#import "MHVType.h"

@interface HealthVaultRecord (Private)

/// Initializes the fields using xml string provided.
/// @param xml - the full XML describing this record.
- (BOOL)parseFromXml: (NSString *)xml;

@end


@implementation HealthVaultRecord

@synthesize xml = _xml;
@synthesize personId = _personId;
@synthesize personName = _personName;
@synthesize recordId = _recordId;
@synthesize recordName = _recordName;
@synthesize relationship = _relationship;
@synthesize displayName = _displayName;
@synthesize authStatus = _authStatus;

+ (id)newFromXml: (NSString *)xml
		personId: (NSString *)personId
	  personName: (NSString *)personName {

	HealthVaultRecord *record = [[HealthVaultRecord alloc] initWithXml: xml
															  personId: personId
															personName: personName];
	if (!record.isValid) {
		return nil;
	}

	return record;

}

- (id)initWithXml: (NSString *)xml
		 personId: (NSString *)personId
	   personName: (NSString *)personName {

	if ((self = [super init])) {

		self.xml = xml;
		self.personId = personId;
		self.personName = personName;

		if (xml != nil)  {

			[self parseFromXml: xml];
		}
		
	}

	return self;
}


- (BOOL)parseFromXml: (NSString *)xml {
    XReader *reader = [[XReader alloc] initFromString:xml];
    [reader readStartElementWithName:@"record"];
    
    self.recordName = [reader readString];
    self.recordId = [reader readAttribute:@"id"];
    self.authStatus = [reader readAttribute:@"app-record-auth-action"];
    
    if (!self.recordId) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)getIsValid {

	return (self.authStatus != nil && [self.authStatus isEqual: @"NoActionRequired"]);
}

@end
