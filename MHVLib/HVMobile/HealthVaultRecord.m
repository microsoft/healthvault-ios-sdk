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

@implementation HealthVaultRecord

+ (id)newFromXml: (NSString *)xml
		personId: (NSUUID *)personId
	  personName: (NSString *)personName
{

	HealthVaultRecord *record = [[HealthVaultRecord alloc] initWithXml: xml
															  personId: personId
															personName: personName];
	if (!record.isValid)
    {
		return nil;
	}

	return record;

}

- (id)initWithXml: (NSString *)xml
		 personId: (NSUUID *)personId
	   personName: (NSString *)personName
{

	if ((self = [super init]))
    {
		self.xml = xml;
		self.personId = personId;
		self.personName = personName;

		if (xml != nil)
        {
			[self parseFromXml: xml];
		}
	}

	return self;
}

- (BOOL)parseFromXml: (NSString *)xml
{
    XReader *reader = [[XReader alloc] initFromString:xml];
    [reader readStartElementWithName:@"record"];
    
    self.recordName = [reader readString];
    self.recordId = [[NSUUID alloc] initWithUUIDString:[reader readAttribute:@"id"]];
    self.authStatus = [reader readAttribute:@"app-record-auth-action"];
    
    return self.recordId != nil;
}

- (BOOL)getIsValid
{
	return (self.authStatus != nil && [self.authStatus isEqual: @"NoActionRequired"]);
}

@end
