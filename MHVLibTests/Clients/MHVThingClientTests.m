//
// MHVThingClientTests.m
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
#import "MHVCommon.h"
#import "MHVThingClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVMethod.h"
#import "MHVAllergy.h"
#import "MHVFile.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVThingClientTests)

describe(@"MHVThingClient", ^
{
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeMethod:completion:) andReturn:nil];
    
    NSUUID *recordId = [[NSUUID alloc] initWithUUIDString:@"20000000-2000-2000-2000-200000000000"];
    
    let(spyExecuteMethod, ^
        {
            return [mockConnection captureArgument:@selector(executeMethod:completion:) atIndex:0];
        });
    
    let(thingClient, ^
        {
            return [[MHVThingClient alloc] initWithConnection:mockConnection];
        });
    
    let(allergyThing, ^
        {
            MHVAllergy *allergy = [[MHVAllergy alloc] initWithName:@"Bees"];
            allergy.reaction = [[MHVCodableValue alloc] initWithText:@"Itching"];
            
            MHVThing *thing = [[MHVThing alloc] initWithTypedData:allergy];
            thing.key = [[MHVThingKey alloc] initWithID:@"AllergyThingKey" andVersion:@"AllergyVersion"];
            
            return thing;
        });

    let(fileThing, ^
        {
            MHVFile *file = [[MHVFile alloc] init];
            
            MHVThing *thing = [[MHVThing alloc] initWithTypedData:file];
            thing.key = [[MHVThingKey alloc] initWithID:@"FileThingKey" andVersion:@"FileVersion"];
            
            return thing;
        });

    context(@"GetThings", ^
            {
                it(@"should get with thing id", ^
                   {
                       [thingClient getThingWithThingId:[[NSUUID alloc] initWithUUIDString:@"10000000-1000-1000-1000-100000000000"]
                                               recordId:recordId
                                             completion:^(MHVThing *_Nullable thing, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><group><id>10000000-1000-1000-1000-100000000000</id><format><section>core</section><xml/></format></group></info>"];
                   });
  
                it(@"should get for thing class", ^
                   {
                       [thingClient getThingsForThingClass:[MHVAllergy class]
                                                     query:[MHVThingQuery new]
                                                  recordId:recordId
                                                completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><group><filter><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><thing-state>Active</thing-state></filter>"\
                        "<format><section>core</section><xml/></format></group></info>"];
                   });
                
            });

    context(@"PutThings", ^
            {
                it(@"should create new thing", ^
                   {
                       [thingClient createNewThing:allergyThing
                                          recordId:recordId
                                        completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"PutThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><flags>0</flags>"\
                        "<data-xml><allergy><name><text>Bees</text></name><reaction><text>Itching</text></reaction></allergy><common/></data-xml></thing></info>"];
                   });
                
                it(@"should update a thing", ^
                   {
                       [thingClient updateThing:allergyThing
                                       recordId:recordId
                                     completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"PutThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id>"\
                        "<type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><flags>0</flags><data-xml>"\
                        "<allergy><name><text>Bees</text></name><reaction><text>Itching</text></reaction></allergy><common/></data-xml></thing></info>"];
                   });
            });

    context(@"DeleteThings", ^
            {
                it(@"should delete a thing", ^
                   {
                       [thingClient removeThing:allergyThing
                                       recordId:recordId
                                     completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"RemoveThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id></info>"];
                   });
            });

    context(@"RefreshBlobs", ^
            {
                it(@"should refresh a thing", ^
                   {
                       [thingClient refreshBlobsForThing:allergyThing
                                                recordId:recordId
                                              completion:^(MHVThing *_Nullable thing, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><group><id>AllergyThingKey</id><format><section>core</section><section>blobpayload</section><xml/></format></group></info>"];
                   });

                it(@"should refresh a thing collection", ^
                   {
                       [thingClient refreshBlobsForThings:[[MHVThingCollection alloc] initWithThings:@[allergyThing, fileThing]]
                                                 recordId:recordId
                                               completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><group><id>AllergyThingKey</id><id>FileThingKey</id><format><section>core</section><section>blobpayload</section><xml/></format></group></info>"];
                   });
            });
});

SPEC_END
