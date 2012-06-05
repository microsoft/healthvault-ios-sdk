//
//  HVGetVocab.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVMethodCallTask.h"
#import "HVVocab.h"

@interface HVVocabGetResults : HVType 
{
    HVVocabSetCollection* m_vocabs;
}

@property (readwrite, nonatomic, retain) HVVocabSetCollection* vocabs;
@property (readonly, nonatomic) HVVocabCodeSet* firstVocab;

@end

//-------------------------
//
// Get Vocabularies from HealthVault
//
//-------------------------
@interface HVGetVocabTask : HVMethodCallTask
{
@private
    HVVocabParams* m_params;
}

//-------------------------
//
// Properties
//
//-------------------------
//
// (Required) - Request - which vocabularies to get
//
@property (readwrite, nonatomic, retain) HVVocabParams* params;
//
// Response - retrieved vocabulary data
//
@property (readonly, nonatomic) HVVocabGetResults* vocabResults;
//
// Convenience property to get the vocabulary from vocabResults
//
@property (readonly, nonatomic) HVVocabCodeSet* vocabulary;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithVocabID:(HVVocabIdentifier *) vocabID andCallback:(HVTaskCompletion) callback;

@end
