//
//  HVVocabIdentifier.h
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

#import "HVType.h"
#import "HVCodedValue.h"

NSString* const c_rxNormFamily;
NSString* const c_snomedFamily;
NSString* const c_hvFamily;
NSString* const c_icdFamily;
NSString* const c_hl7Family;
NSString* const c_isoFamily;

@interface HVVocabIdentifier : HVType
{
@private
    NSString* m_name;
    NSString* m_family;
    NSString* m_version;
    NSString* m_lang;
    NSString* m_codeValue;
    
    NSString* m_keyString;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - the vocabulary name. E.g Rx Norm Active Medications
//
@property (readwrite, nonatomic, retain) NSString* name;
//
// (Optional) - e.g. RxNorm...
//
@property (readwrite, nonatomic, retain) NSString* family;
//
// (Optional) Vocabulary version
//
@property (readwrite, nonatomic, retain) NSString* version;
//
// (Optional) Language, in ISO code. E.g. 'en'. 
//
@property (readwrite, nonatomic, retain) NSString* language;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* codeValue;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithFamily:(NSString *) family andName:(NSString *) name;

//-------------------------
//
// Methods
//
//-------------------------
//
// Create a codedValue for the vocabItem
//
-(HVCodedValue *) codedValueForItem:(HVVocabItem *) vocabItem;
//
// Generate a single string representing this vocab identifier
//
-(NSString *) toKeyString;

@end

@interface HVVocabIdentifierCollection :  HVCollection 

@end