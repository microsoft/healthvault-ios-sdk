//
// MHVVocabularyClientTests.m
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
#import "MHVVocabularyClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVMethod.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVVocabularyClientTests)

describe(@"MHVVocabularyClient", ^
{
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) andReturn:nil];
    
    let(spyExecuteMethod, ^
        {
            return [mockConnection captureArgument:@selector(executeHttpServiceOperation:completion:) atIndex:0];
        });
    
    let(vocabularyClient, ^
        {
            return [[MHVVocabularyClient alloc] initWithConnection:mockConnection];
        });
    
    context(@"GetVocabularyKeys", ^
            {
                it(@"should get vocabulary keys", ^
                   {
                       [vocabularyClient getVocabularyKeysWithCompletion:^(MHVVocabularyKeyCollection * _Nullable vocabularyKeys, NSError * _Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should] beNil];
                   });
            });
    
    context(@"GetVocabulary", ^
            {
                it(@"should get with single key", ^
                   {
                       MHVVocabularyKey *testKey = [[MHVVocabularyKey alloc]init];
                       [testKey setName:@"Test key name"];
                       [testKey setFamily:@"Test family"];
                       [testKey setDescriptionText:@"Test description"];
                       [testKey setVersion:@"Test version"];
                       [testKey setCode:@"Test code"];
                       
                       [vocabularyClient getVocabularyWithKey:testKey cultureIsFixed:NO completion:^(MHVVocabularyCodeSet * _Nullable vocabulary, NSError * _Nullable error) {
                       }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should]equal:@"<info><vocabulary-parameters><vocabulary-key><code-value>Test code</code-value><name>Test key name</name><family>Test family</family><version>Test version</version></vocabulary-key><fixed-culture>false</fixed-culture></vocabulary-parameters></info>"];
                   });
                
                it(@"should get with multiple keys", ^
                   {
                       MHVVocabularyKey *testKey1 = [[MHVVocabularyKey alloc]init];
                       [testKey1 setName:@"Name 1"];
                       [testKey1 setFamily:@"Family 1"];
                       [testKey1 setDescriptionText:@"Description 1"];
                       [testKey1 setVersion:@"Version 1"];
                       [testKey1 setCode:@"Code 1"];
                       
                       MHVVocabularyKey *testKey2 = [[MHVVocabularyKey alloc]init];
                       [testKey2 setName:@"Name 2"];
                       [testKey2 setFamily:@"Family 2"];
                       [testKey2 setDescriptionText:@"Description 2"];
                       [testKey2 setVersion:@"Version 2"];
                       [testKey2 setCode:@"Code 2"];
                       
                       MHVVocabularyKeyCollection *keys = [[MHVVocabularyKeyCollection alloc]initWithArray:@[testKey1, testKey2]];
                       
                       [vocabularyClient getVocabulariesWithVocabularyKeys:keys cultureIsFixed:NO completion:
                        ^(MHVVocabularyCodeSetCollection * _Nullable vocabularies, NSError * _Nullable error) {}];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should] equal:@"GetVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should]equal:@"<info><vocabulary-parameters><vocabulary-key><code-value>Code 1</code-value><name>Name 1</name><family>Family 1</family><version>Version 1</version></vocabulary-key><vocabulary-key><code-value>Code 2</code-value><name>Name 2</name><family>Family 2</family><version>Version 2</version></vocabulary-key><fixed-culture>false</fixed-culture></vocabulary-parameters></info>"];
                       
                   });
            });
    context(@"SearchVocabularies", ^
            {
                it(@"should search without vocabulary key", ^
                   {
                       [vocabularyClient searchVocabularyKeysWithSearchValue:@"SearchText" searchMode:MHVSearchModeContains maxResults:[NSNumber numberWithInteger:10] completion:^(MHVVocabularyKeyCollection * _Nullable vocabularyKeys, NSError * _Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should]equal:@"SearchVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should]equal:@"<info><text-search-parameters><search-string search-mode=\"Contains\">SearchText</search-string><max-results>10</max-results></text-search-parameters></info>"];
                   });
                
                it(@"should search without vocabulary key and nil maxResults", ^
                   {
                       [vocabularyClient searchVocabularyKeysWithSearchValue:@"SearchText" searchMode:MHVSearchModeContains maxResults:nil completion:^(MHVVocabularyKeyCollection * _Nullable vocabularyKeys, NSError * _Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should]equal:@"SearchVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should]equal:@"<info><text-search-parameters><search-string search-mode=\"Contains\">SearchText</search-string><max-results>25</max-results></text-search-parameters></info>"];
                       
                   });
                
                it(@"should search with vocabulary key", ^
                   {
                       MHVVocabularyKey *testKey = [[MHVVocabularyKey alloc]init];
                       [testKey setName:@"Test key name"];
                       [testKey setFamily:@"Test family"];
                       [testKey setDescriptionText:@"Test description"];
                       [testKey setVersion:@"Test version"];
                       [testKey setCode:@"Test code"];
                       
                       [vocabularyClient searchVocabularyWithSearchValue:@"SearchText" searchMode:MHVSearchModeContains vocabularyKey:testKey maxResults:nil completion:^(MHVVocabularyCodeSetCollection * _Nullable codeSet, NSError * _Nullable error) {}];
                       
                       MHVMethod *method = (MHVMethod *)spyExecuteMethod.argument;
                       
                       [[method.name should]equal:@"SearchVocabulary"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.parameters should]equal:@"<info><vocabulary-key><code-value>Test code</code-value><name>Test key name</name><family>Test family</family><version>Test version</version></vocabulary-key><text-search-parameters><search-string search-mode=\"Contains\">SearchText</search-string><max-results>25</max-results></text-search-parameters></info>"];
                   });
            });
});

SPEC_END



