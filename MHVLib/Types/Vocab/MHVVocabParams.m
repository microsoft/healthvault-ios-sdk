//
//  MHVVocabParams.m
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
#import "MHVVocabParams.h"

static NSString* const c_element_vocabkey = @"vocabulary-key";
static NSString* const c_element_culture = @"fixed-culture";

@implementation MHVVocabParams

-(MHVVocabIdentifierCollection *)vocabIDs
{
    MHVENSURE(m_vocabIDs, MHVVocabIdentifierCollection);
    return m_vocabIDs;
}

@synthesize fixedCulture = m_fixedCulture;

-(id)initWithVocabID:(MHVVocabIdentifier *)vocabID
{
    MHVCHECK_NOTNULL(vocabID);
    
    self = [super init];
    MHVCHECK_SELF;

    [self.vocabIDs addObject:vocabID];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithVocabIDs:(MHVVocabIdentifierCollection *)vocabIDs
{
    MHVCHECK_NOTNULL(vocabIDs);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_vocabIDs = vocabIDs;
    
    return self;
    
LError:
    MHVALLOC_FAIL;    
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(m_vocabIDs, MHVClientError_InvalidVocabIdentifier);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_vocabkey elements:m_vocabIDs];
    [writer writeElement:c_element_culture boolValue:m_fixedCulture];
}

-(void)deserialize:(XReader *)reader
{
    m_vocabIDs = (MHVVocabIdentifierCollection *)[reader readElementArray:c_element_vocabkey asClass:[MHVVocabIdentifier class] andArrayClass:[MHVVocabIdentifierCollection class]];
    m_fixedCulture = [reader readBoolElement:c_element_culture];
}

@end
