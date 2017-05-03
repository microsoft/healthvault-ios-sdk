//
//  HVSearchVocabTask.m
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
#import "HVVocabSearchTask.h"

static NSString* const c_element_vocab = @"vocabulary-key";
static NSString* const c_element_params = @"text-search-parameters";

@implementation HVVocabSearchTask

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

-(HVVocabCodeSet *)searchResult
{
    HVVocabSearchResults* results = (HVVocabSearchResults *) self.result;
    return results.hasMatches ? results.match : nil;
}

-(id)initWithVocab:(HVVocabIdentifier *)vocab searchText:(NSString *)text andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(vocab);
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.vocabID = vocab;
    
    m_params = [[HVVocabSearchParams alloc] initWithText:text];
    HVCHECK_NOTNULL(m_params);
    
    return self;
    
LError:
    HVALLOC_FAIL;
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
    return [super deserializeResponseBodyFromReader:reader asClass:[HVVocabSearchResults class]];
}

+(HVVocabSearchTask *)searchForText:(NSString *)text inVocabFamily:(NSString *)family vocabName:(NSString *)name callback:(HVTaskCompletion)callback
{
    HVVocabIdentifier* vocab = [[HVVocabIdentifier alloc] initWithFamily:family andName:name];
    HVCHECK_NOTNULL(vocab);
    
    HVVocabSearchTask* searchTask = [HVVocabSearchTask searchForText:text inVocab:vocab callback:callback];
    
    return searchTask;

LError:
    return nil;
}

+(HVVocabSearchTask *)searchForText:(NSString *)text inVocab:(HVVocabIdentifier *)vocab callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(vocab);
    
    HVVocabSearchTask* searchTask = [[HVVocabSearchTask alloc] initWithVocab:vocab searchText:text andCallback:callback];
    HVCHECK_NOTNULL(searchTask);
    
    [searchTask start];    
    
    return searchTask;
    
LError:
    return nil;    
}

+(HVVocabSearchTask *)searchMedications:(NSString *)text callback:(HVTaskCompletion)callback
{
    return [HVVocabSearchTask searchForText:text inVocabFamily:@"RxNorm" vocabName:@"RxNorm Active Medicines" callback:callback];
}

@end
