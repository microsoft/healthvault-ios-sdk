//
//  HVGetVocab.m
//  HVLib
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

#import "HVCommon.h"
#import "HVGetVocabTask.h"

static NSString* const c_element_vocab = @"vocabulary";

@implementation HVVocabGetResults

@synthesize vocabs = m_vocabs;

-(HVVocabCodeSet *)firstVocab
{
    return (m_vocabs) ? [m_vocabs itemAtIndex:0] : nil;
}


-(void)serialize:(XWriter *)writer  
{
    [writer writeElementArray:c_element_vocab elements:m_vocabs];
}

-(void)deserialize:(XReader *)reader
{
    m_vocabs = (HVVocabSetCollection *)[reader readElementArray:c_element_vocab asClass:[HVVocabCodeSet class] andArrayClass:[HVVocabSetCollection class]];
}

@end

@implementation HVGetVocabTask

@synthesize params = m_params;

-(NSString *)name
{
    return @"GetVocabulary";
}

-(float)version
{
    return 2;
}

-(HVVocabGetResults *) vocabResults
{
    return (HVVocabGetResults *) self.result;
}

-(HVVocabCodeSet *)vocabulary
{
    HVVocabGetResults* results = self.vocabResults;
    return (results) ? results.firstVocab : nil;
}

-(id)initWithVocabID:(HVVocabIdentifier *)vocabID andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(vocabID);
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_params = [[HVVocabParams alloc] initWithVocabID:vocabID];
    HVCHECK_NOTNULL(m_params);
        
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    [self validateObject:m_params];
    [XSerializer serialize:m_params withRoot:@"vocabulary-parameters" toWriter:writer];
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[HVVocabGetResults class]];
}

@end
