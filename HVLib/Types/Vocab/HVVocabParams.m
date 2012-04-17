//
//  HVVocabParams.m
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

#import "HVCommon.h"
#import "HVVocabParams.h"

static NSString* const c_element_vocabkey = @"vocabulary-key";
static NSString* const c_element_culture = @"fixed-culture";

@implementation HVVocabParams

@synthesize vocabID = m_vocabID;
@synthesize fixedCulture = m_fixedCulture;

-(id)initWithVocabID:(HVVocabIdentifier *)vocabID
{
    HVCHECK_NOTNULL(vocabID);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.vocabID = vocabID;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_vocabID release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_vocabID, HVClientError_InvalidVocabIdentifier);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_vocabID, c_element_vocabkey);
    HVSERIALIZE_BOOL(m_fixedCulture, c_element_culture);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_vocabID, c_element_vocabkey, HVVocabIdentifier);
    HVDESERIALIZE_BOOL(m_fixedCulture, c_element_culture);
}

@end
