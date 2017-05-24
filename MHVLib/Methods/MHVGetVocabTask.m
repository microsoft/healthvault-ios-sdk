//
//  MHVGetVocab.m
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

#import "MHVCommon.h"
#import "MHVGetVocabTask.h"

static NSString* const c_element_vocab = @"vocabulary";

@implementation MHVVocabularyGetResults

@synthesize vocabs = m_vocabs;

-(MHVVocabularyCodeSet *)firstVocab
{
    return (m_vocabs) ? [m_vocabs objectAtIndex:0] : nil;
}


-(void)serialize:(XWriter *)writer  
{
    [writer writeElementArray:c_element_vocab elements:m_vocabs.toArray];
}

-(void)deserialize:(XReader *)reader
{
    m_vocabs = (MHVVocabularySetCollection *)[reader readElementArray:c_element_vocab asClass:[MHVVocabularyCodeSet class] andArrayClass:[MHVVocabularySetCollection class]];
}

@end

@implementation MHVGetVocabTask

@synthesize params = m_params;

-(NSString *)name
{
    return @"GetVocabulary";
}

-(float)version
{
    return 2;
}

-(MHVVocabularyGetResults *) vocabResults
{
    return (MHVVocabularyGetResults *) self.result;
}

-(MHVVocabularyCodeSet *)vocabulary
{
    MHVVocabularyGetResults* results = self.vocabResults;
    return (results) ? results.firstVocab : nil;
}

-(id)initWithVocabID:(MHVVocabularyIdentifier *)vocabID andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(vocabID);
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    m_params = [[MHVVocabularyParams alloc] initWithVocabID:vocabID];
    MHVCHECK_NOTNULL(m_params);
        
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    [self validateObject:m_params];
    [XSerializer serialize:m_params withRoot:@"vocabulary-parameters" toWriter:writer];
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVVocabularyGetResults class]];
}

@end
