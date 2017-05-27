////
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
#import "MHVVocabularyCodeItem.h"
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

- (void)getVocabularyKeysWithCompletion:(void(^)(MHVVocabularyKeyCollection *_Nullable vocabularyKeys, NSError *_Nullable error))completion
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

- (void)getVocabularyWithKey:(MHVVocabularyKey *)key
              cultureIsFixed:(NSNumber *_Nullable)cultureIsFixed
                  completion:(void(^)(MHVVocabularyCodeSet *_Nullable vocabulary, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(key);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion) {
        return;
    }
    
    [self getVocabulariesWithVocabularyKeys:[[MHVVocabularyKeyCollection alloc]initWithArray:@[key]] cultureIsFixed:cultureIsFixed completion:^(MHVVocabularyCodeSetCollection * _Nullable vocabularies, NSError * _Nullable error)
    {
        if (error || !vocabularies || [vocabularies count] <= 0)
        {
            completion(nil, error);
            return;
        }
        
        completion([vocabularies objectAtIndex:0], nil);
        return;
    }];
    
    return;
}

- (void)getVocabulariesWithVocabularyKeys:(MHVVocabularyKeyCollection *)vocabularyKeys
                           cultureIsFixed:(NSNumber *_Nullable)cultureIsFixed
                               completion:(void(^)(MHVVocabularyCodeSetCollection* _Nullable vocabularies, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(vocabularyKeys);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion || !vocabularyKeys) {
        return;
    }
    
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    [writer writeStartElement:@"info"];
    [writer writeStartElement:@"vocabulary-parameters"];
    
    for (MHVVocabularyKey *key in vocabularyKeys)
    {
        [writer writeStartElement:@"vocabulary-key"];
        [key serialize:writer];
        [writer writeEndElement];
    }
    
    [writer writeElement:@"fixed-culture" boolValue:[cultureIsFixed isEqualToNumber:[NSNumber numberWithBool:YES]]];
    [writer writeEndElement];   // </vocabulary-parameters>
    [writer writeEndElement];   // </info>
    
    MHVMethod *method = [MHVMethod getVocabulary];
    method.parameters = [writer newXmlString];
    [self.connection executeMethod:method completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            return;
        }
        
        MHVVocabularyCodeSetCollection *vocabularies = (MHVVocabularyCodeSetCollection*)[XSerializer newFromString:response.infoXml withRoot:@"info" andElementName:@"vocabulary" asClass:[MHVVocabularyCodeSet class] andArrayClass:[MHVVocabularyCodeSetCollection class]];
        
        completion(vocabularies, nil);
        return;
    }];
}

- (void)searchVocabularyWithSearchValue:(NSString *)searchValue
                             searchMode:(MHVSearchMode)searchMode
                             vocabularyKey:(MHVVocabularyKey * _Nullable)vocabularyKey
                             maxResults:(NSNumber *_Nullable)maxResults
                             completion:(void(^)(MHVVocabularyCodeSetCollection *_Nullable vocabularyKeys, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(searchValue);
    MHVASSERT_PARAMETER(searchMode);
    MHVASSERT_PARAMETER(completion);
    
    if (!searchValue || !searchMode || !completion) {
        return;
    }
    
    MHVVocabularySearchParams *searchParams = [[MHVVocabularySearchParams alloc] initWithText:searchValue];
    [searchParams.text setMatchType:searchMode];
    if (maxResults)
    {
        [searchParams setMaxResults:[maxResults integerValue]];
    }
    
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    [writer writeStartElement:@"info"];
    
    if (vocabularyKey)
    {
        [writer writeStartElement:@"vocabulary-key"];
        [vocabularyKey serialize:writer];
        [writer writeEndElement];   // </vocabulary-key>
    }
    
    [writer writeStartElement:@"text-search-parameters"];
    [searchParams serialize:writer];
    [writer writeEndElement];   // </text-search-parameters>
    [writer writeEndElement];   // </info>
    
    MHVMethod *method = [MHVMethod searchVocabulary];
    method.parameters = [writer newXmlString];
    
    [self.connection executeMethod:method completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            return;
        }
        
        // If no key is provided we search the keys
        // if key is provided we search the
        /*
         Not fully sure what this method is supposed to do, we have different behaviour depending on values passed.
         MAybe it should be two methods. One for seaching within a provided key, and one for searching all keys. 
         
         - Documentation: https://developer.healthvault.com/Methods/ResponseSchema?Name=SearchVocabulary&Version=1 
         makes it seem like we should always get the code-set-result object, and then a variable number of vocabkeys
         but in reality it seems like we either get one or the other
         */
        MHVVocabularyCodeSetCollection *vocabularies = (MHVVocabularyCodeSetCollection*)[XSerializer newFromString:response.infoXml withRoot:@"info" andElementName:@"code-set-result" asClass:[MHVVocabularyCodeSet class] andArrayClass:[MHVVocabularyCodeSetCollection class]];
        
        completion(vocabularies, nil);
        return;
    }];
}

@end
