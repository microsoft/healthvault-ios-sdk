//
//  Provisioner.m
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

#import "MHVCommon.h"
#import "Provisioner.h"
#import "HealthVaultService.h"
#import "AuthenticationCheckState.h"
#import "XmlTextReader.h"

@interface Provisioner (HVPrivate)

/// Checks that the application is authenticated.
/// @param state - the state information.
-(void)performAuthenticationCheck: (AuthenticationCheckState *)state;

/// Makes the CreateAuthenticatedSessionToken call.
/// @param state - the state information.
-(void)castCall: (AuthenticationCheckState *)state;

/// Gets the list of authorized people.
/// @param state - the state information.
-(void)getAuthorizedPeople: (AuthenticationCheckState *)state;

/// Gets the new application info from the HealthVault platform.
/// @param state - the state information.
-(void)startNewApplicationCreationInfo: (AuthenticationCheckState *)state;

@end


@implementation Provisioner


-(void)authorizeRecords: (HealthVaultService *)service
                  target: (NSObject *)target
 authenticationCompleted: (SEL)authCompleted
       shellAuthRequired: (SEL)shellAuthRequired {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector: shellAuthRequired];
#pragma clang diagnostic pop
}

-(void)performAuthenticationCheck: (HealthVaultService *)service
                            target: (NSObject *)target
           authenticationCompleted: (SEL)authCompleted
                 shellAuthRequired: (SEL)shellAuthRequired {

    AuthenticationCheckState *state = [[AuthenticationCheckState alloc] initWithService: service
																				 target: target
																  authCompletedCallBack: authCompleted
															  shellAuthRequiredCallBack: shellAuthRequired];
    [self performAuthenticationCheck: state];
}

@end

@implementation Provisioner (HVPrivate)

-(void)performAuthenticationCheck: (AuthenticationCheckState *)state {

    if (state.service.authorizationSessionToken && state.service.sharedSecret) {

        // We have a session token for the app, but we don't know who authorized the app.
        // We'll call GetAuthorizedPeople.
        [self getAuthorizedPeople: state];
    }
    else if (state.service.sharedSecret) {

        // We have a shared secret, but not a session token. We will try a CAST call,
        // which will work if the app.
        // is auth'd; if it fails, we'll need to ask the application to do the auth.
        [self castCall: state];
    }
    else {

        // We're just starting. Call newApplicationCreationInfo.
        [self startNewApplicationCreationInfo: state];
    }
}

-(void)castCall: (AuthenticationCheckState *)state {

    NSString *infoSection = [state.service getCastCallInfoSection];

    HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"CreateAuthenticatedSessionToken"
																   methodVersion: 2
																	 infoSection: infoSection
																		  target: self
																		callBack: @selector(castCallCompleted:)];
    request.userState = state;
    [state.service sendRequest: request];
}

-(void)castCallCompleted: (HealthVaultResponse *)response {

    AuthenticationCheckState *state = (AuthenticationCheckState *)response.request.userState;

    if (response.statusCode == RESPONSE_INVALID_APPLICATION) {

        // Force creation of app from scratch.
        state.service.sharedSecret = nil;
        state.service.appIdInstance = nil;
    }
    else if (response.errorText) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [state.target performSelector: state.shellAuthRequiredCallBack
                           withObject: response];
#pragma clang diagnostic pop
        return;
    }
    else {

        [state.service saveCastCallResults: response.infoXml];
    }

    [self performAuthenticationCheck: state];
}

-(void)getAuthorizedPeople: (AuthenticationCheckState *)state {

    NSString *infoSection = @"<info><parameters></parameters></info>";

    HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"GetAuthorizedPeople"
																   methodVersion: 1
																	 infoSection: infoSection
																		  target: self
																		callBack: @selector(getAuthorizedPeopleCompleted:)];
    request.userState = state;
    [state.service sendRequest: request];
}

-(void)getAuthorizedPeopleCompleted: (HealthVaultResponse *)response {

    AuthenticationCheckState *state = (AuthenticationCheckState *)response.request.userState;

    if (response.hasError) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [state.target performSelector: state.authCompletedCallBack
                           withObject: response];
#pragma clang diagnostic pop
        return;
    }

    // Clears all current records.
    [state.service.records removeAllObjects];

    @autoreleasepool {

        XmlTextReader *xmlReader = [XmlTextReader new];
        XmlElement *infoNode = [xmlReader read: response.infoXml];

        XmlElement *responseResults = [infoNode selectSingleNode: @"response-results"];
        XmlElement *personInfo = [responseResults selectSingleNode: @"person-info"];

        if (personInfo) {

            NSString *personId = [personInfo selectSingleNode: @"person-id"].text;
            NSString *personName = [personInfo selectSingleNode: @"name"].text;

            // If we loaded our settings, the current record is incomplete. We will try
            // to match it to one that we got back...
            HealthVaultRecord *currentRecord = state.service.currentRecord;

            NSArray *recordNodes = [personInfo selectNodes: @"record"];

            for (XmlElement *recordNode in recordNodes) {

                HealthVaultRecord *record = [[HealthVaultRecord alloc] initWithXml: nil
																	  personId: personId
																	personName: personName];
                record.recordId = [recordNode attrValue: @"id"];
                record.relationship = [recordNode attrValue:@"rel-name"];
                record.recordName = [recordNode text];
                record.displayName = [recordNode attrValue:@"display-name"];
                record.authStatus = [recordNode attrValue: @"app-record-auth-action"];

                if (!record.isValid) {

                    continue;
                }

                [state.service.records addObject: record];

			BOOL isRecordEqualToCurrent = currentRecord && 
				[currentRecord.personId isEqualToString: record.personId] &&
				[currentRecord.recordId isEqualToString: record.recordId];
			
                if (!currentRecord || isRecordEqualToCurrent) {

                    state.service.currentRecord = record;
                }

            }
        }

    }

    if (state.service.records.count > 0) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [state.target performSelector: state.authCompletedCallBack
                           withObject: response];
#pragma clang diagnostic pop
    }
    else {

		// Agreed to create new application instance every time the application 
		// does not have authorized persons.
		// [state.target performSelector: state.shellAuthRequiredCallBack
		//				   withObject: response];
		
		[self startNewApplicationCreationInfo: state];
    }
}

-(void)startNewApplicationCreationInfo: (AuthenticationCheckState *)state {

	// Need to reset all parameters to make a correct request.
	state.service.appIdInstance = nil;
	state.service.authorizationSessionToken = nil;
	state.service.sessionSharedSecret = nil;
	state.service.currentRecord = nil;
	
    HealthVaultRequest *request = [[HealthVaultRequest alloc] initWithMethodName: @"NewApplicationCreationInfo"
																   methodVersion: 1
																	 infoSection: nil
																		  target: self
																		callBack: @selector(newApplicationCreationInfoCompleted:)];
    request.userState = state;
    [state.service sendRequest: request];
}

-(void)newApplicationCreationInfoCompleted: (HealthVaultResponse *)response {

    AuthenticationCheckState *state = (AuthenticationCheckState *)response.request.userState;

    if (response.errorText) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [state.target performSelector: state.authCompletedCallBack
                           withObject: response];
#pragma clang diagnostic pop
        return;
    }

    @autoreleasepool {

        XmlTextReader *xmlReader = [XmlTextReader new];
        XmlElement *infoNode = [xmlReader read: response.infoXml];

        state.service.appIdInstance = [infoNode selectSingleNode: @"app-id"].text;
        state.service.sharedSecret = [infoNode selectSingleNode: @"shared-secret"].text;
        state.service.applicationCreationToken = [infoNode selectSingleNode: @"app-token"].text;

    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [state.target performSelector: state.shellAuthRequiredCallBack
                       withObject: response];
#pragma clang diagnostic pop
}

@end
