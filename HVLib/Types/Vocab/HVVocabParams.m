//
//  HVVocabParams.m
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
#import "HVVocabParams.h"

static NSString* const c_element_vocabkey = @"vocabulary-key";
static NSString* const c_element_culture = @"fixed-culture";

@implementation HVVocabParams

-(HVVocabIdentifierCollection *)vocabIDs
{
    HVENSURE(m_vocabIDs, HVVocabIdentifierCollection);
    return m_vocabIDs;
}

@synthesize fixedCulture = m_fixedCulture;

-(id)initWithVocabID:(HVVocabIdentifier *)vocabID
{
    HVCHECK_NOTNULL(vocabID);
    
    self = [super init];
    HVCHECK_SELF;

    [self.vocabIDs addObject:vocabID];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithVocabIDs:(HVVocabIdentifierCollection *)vocabIDs
{
    HVCHECK_NOTNULL(vocabIDs);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_vocabIDs = vocabIDs;
    
    return self;
    
LError:
    HVALLOC_FAIL;    
}


-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_vocabIDs, HVClientError_InvalidVocabIdentifier);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_vocabkey elements:m_vocabIDs];
    [writer writeElement:c_element_culture boolValue:m_fixedCulture];
}

-(void)deserialize:(XReader *)reader
{
    m_vocabIDs = (HVVocabIdentifierCollection *)[reader readElementArray:c_element_vocabkey asClass:[HVVocabIdentifier class] andArrayClass:[HVVocabIdentifierCollection class]];
    m_fixedCulture = [reader readBoolElement:c_element_culture];
}

@end
