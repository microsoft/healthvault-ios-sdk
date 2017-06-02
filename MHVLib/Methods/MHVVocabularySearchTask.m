//
//  MHVSearchVocabTask.m
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
#import "MHVVocabularySearchTask.h"

static NSString* const c_element_vocab = @"vocabulary-key";
static NSString* const c_element_params = @"text-search-parameters";

@implementation MHVVocabularySearchTask

@synthesize vocabID = m_vocabID;
@synthesize params = m_params;

-(NSString *)name
{
    return @"SearchVocabulary";
}

-(float)version
{
    return 1;
}

-(MHVVocabularyCodeSet *)searchResult
{
    MHVVocabularySearchResults* results = (MHVVocabularySearchResults *) self.result;
    return results.hasMatches ? results.match : nil;
}

-(id)initWithVocab:(MHVVocabularyIdentifier *)vocab searchText:(NSString *)text andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(vocab);
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    self.vocabID = vocab;
    
    m_params = [[MHVVocabularySearchParams alloc] initWithText:text];
    MHVCHECK_NOTNULL(m_params);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    [self validateObject:m_vocabID];
    [self validateObject:m_params];
    
    [XSerializer serialize:m_vocabID withRoot:c_element_vocab toWriter:writer];
    [XSerializer serialize:m_params withRoot:c_element_params toWriter:writer];
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [super deserializeResponseBodyFromReader:reader asClass:[MHVVocabularySearchResults class]];
}

+(MHVVocabularySearchTask *)searchForText:(NSString *)text inVocabFamily:(NSString *)family vocabName:(NSString *)name callback:(MHVTaskCompletion)callback
{
    MHVVocabularyIdentifier* vocab = [[MHVVocabularyIdentifier alloc] initWithFamily:family andName:name];
    MHVCHECK_NOTNULL(vocab);
    
    MHVVocabularySearchTask* searchTask = [MHVVocabularySearchTask searchForText:text inVocab:vocab callback:callback];
    
    return searchTask;

LError:
    return nil;
}

+(MHVVocabularySearchTask *)searchForText:(NSString *)text inVocab:(MHVVocabularyIdentifier *)vocab callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(vocab);
    
    MHVVocabularySearchTask* searchTask = [[MHVVocabularySearchTask alloc] initWithVocab:vocab searchText:text andCallback:callback];
    MHVCHECK_NOTNULL(searchTask);
    
    [searchTask start];    
    
    return searchTask;
    
LError:
    return nil;    
}

+(MHVVocabularySearchTask *)searchMedications:(NSString *)text callback:(MHVTaskCompletion)callback
{
    return [MHVVocabularySearchTask searchForText:text inVocabFamily:@"RxNorm" vocabName:@"RxNorm Active Medicines" callback:callback];
}

@end
