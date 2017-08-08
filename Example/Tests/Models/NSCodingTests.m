//
//  NSCodingTests.m
//  MHVLib
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
#import "MHVThingKey.h"
#import "MHVAllergy.h"
#import "MHVHeartRate.h"
#import "Kiwi.h"

SPEC_BEGIN(NSCodingTests)

describe(@"MHVThing", ^
{
    context(@"conforming to NSCoding", ^
            {
                let(thing, ^
                    {
                        MHVAllergy *allergy = [[MHVAllergy alloc] initWithName:@"TestAllergy"];
                        allergy.reaction = [[MHVCodableValue alloc] initWithText:@"TestReaction"];
                        allergy.isNegated = [[MHVBool alloc] initWith:YES];
                        
                        MHVThing *thing = [[MHVThing alloc] initWithTypedData:allergy];
                        thing.key = [[MHVThingKey alloc] initWithID:@"000000-1111-2222-33333333" andVersion:@"1.2.3"];
                        
                        return thing;
                    });
                
                __block NSData *data;
                __block MHVThing *decodedThing;
                
                beforeEach(^
                           {
                               NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] init];
                               [archiver encodeObject:thing forKey:@"Test"];
                               
                               data = archiver.encodedData;
                               
                               NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                               
                               decodedThing = [unarchiver decodeObjectForKey:@"Test"];
                           });
                
                it(@"should archive Thing to data", ^
                   {
                       [[data should] beNonNil];
                   });
                
                it(@"should unarchive MHVThing from data", ^
                   {
                       [[decodedThing.key.thingID should] equal:@"000000-1111-2222-33333333"];
                       [[decodedThing.key.version should] equal:@"1.2.3"];
                       
                       [[[decodedThing.data.typed class] should] equal:[MHVAllergy class]];
                       
                       MHVAllergy *decodedAllergy = (MHVAllergy *)decodedThing.data.typed;
                       [[decodedAllergy.name.text should] equal:@"TestAllergy"];
                       [[decodedAllergy.reaction.text should] equal:@"TestReaction"];
                       [[theValue(decodedAllergy.isNegated.value) should] equal:theValue(YES)];
                   });
            });
    
});

SPEC_END
