//
//  HVGetVocab.h
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "MHVMethodCallTask.h"
#import "MHVVocab.h"

@interface MHVVocabGetResults : MHVType 
{
    MHVVocabSetCollection* m_vocabs;
}

@property (readwrite, nonatomic, strong) MHVVocabSetCollection* vocabs;
@property (readonly, nonatomic, strong) MHVVocabCodeSet* firstVocab;

@end

//-------------------------
//
// Get Vocabularies from HealthVault
//
//-------------------------
@interface MHVGetVocabTask : MHVMethodCallTask
{
@private
    MHVVocabParams* m_params;
}

//-------------------------
//
// Properties
//
//-------------------------
//
// (Required) - Request - which vocabularies to get
//
@property (readwrite, nonatomic, strong) MHVVocabParams* params;
//
// Response - retrieved vocabulary data
//
@property (readonly, nonatomic, strong) MHVVocabGetResults* vocabResults;
//
// Convenience property to get the vocabulary from vocabResults
//
@property (readonly, nonatomic, strong) MHVVocabCodeSet* vocabulary;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithVocabID:(MHVVocabIdentifier *) vocabID andCallback:(HVTaskCompletion) callback;

@end
