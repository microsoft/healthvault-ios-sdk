//
//  HVAllergy.h
//  HVLib
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
#import "HVTypes.h"
#import "HVVocab.h"

@interface HVAllergy : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVCodableValue* m_reaction;
    HVApproxDateTime* m_firstObserved;
    HVCodableValue* m_allergenType;
    HVCodableValue* m_allergenCode;
    HVPerson* m_treatmentProvider;
    HVCodableValue* m_treatment;
    HVBool* m_isNegated;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) E.g. Allergy to Pollen
//
@property (readwrite, nonatomic, retain) HVCodableValue* name;
//
// (Optional) Reaction to the allergy
// Preferred Vocab: icd9cm
//
@property (readwrite, nonatomic, retain) HVCodableValue* reaction;
//
// (Optional) Approximately when first observed
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* firstObserved;
//
// (Optional) E.g. Pollen
// Preferred Vocab: allergen-type
//
@property (readwrite, nonatomic, retain) HVCodableValue* allergenType;
//
// (Optional) Clinical allergen code
// Preferred Vocab: icd9cm
//
@property (readwrite, nonatomic, retain) HVCodableValue* allergenCode;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVPerson* treatmentProvider;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* treatment;
//
// (Optional) - Does treatment negate the effects of the allergy? 
//
@property (readwrite, nonatomic, retain) HVBool* isNegated;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithName:(NSString *) name;

//-------------------------
//
// Standard Vocabs
//
//-------------------------
+(HVVocabIdentifier *) vocabForType;
+(HVVocabIdentifier *) vocabForReaction;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

-(NSString *) toString;

+(HVItem *) newItem;

@end
