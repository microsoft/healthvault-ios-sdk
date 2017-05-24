//
//  MHVVocabularyClient.m
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

#import "MHVVocabularyClient.h"
#import "MHVValidator.h"
#import "MHVMethod.h"
#import "MHVServiceResponse.h"
#import "MHVConnectionProtocol.h"

@interface MHVVocabularyClient ()

@property (nonatomic, weak) id<MHVConnectionProtocol> connection;

@end

@implementation MHVVocabularyClient

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection
{
    MHVASSERT_PARAMETER(connection);
    
    self = [super init];
    if (self)
    {
        _connection = connection;
    }
    return self;
}

- (void)getVocabularyKeysWithCompletion:(void(^)(NSArray<MHVVocabularyKey *> *_Nullable vocabularyKeys, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    MHVMethod *method = [MHVMethod getVocabulary];
    
    [self.connection executeMethod:method completion:^(MHVServiceResponse *_Nullable response, NSError  *_Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            return;
        }
        
        MHVVocabularyKeyCollection *vocabularyKeys = (MHVVocabularyKeyCollection*)[XSerializer newFromString:response.infoXml withRoot:@"info" andElementName:@"vocabulary-key" asClass:[MHVVocabularyKey class] andArrayClass:[MHVVocabularyKeyCollection class]];
        
        completion(vocabularyKeys, nil);
        return;
    }];
}



@end
