//
//  HVImmunization.h
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"
#import "HVVocab.h"

@interface HVImmunization : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVApproxDateTime* m_administeredDate;
    HVPerson* m_administrator;
    HVCodableValue* m_manufacturer;
    NSString* m_lot;
    HVCodableValue* m_route;
    HVApproxDate* m_expiration;
    NSString* m_sequence;
    HVCodableValue* m_anatomicSurface;
    NSString* m_adverseEvent;
    NSString* m_consent;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) immunization name
// Vocabularies: vaccines-cvx (HL7), immunizations, immunizations-common
//
@property (readwrite, nonatomic, strong) HVCodableValue* name;
//
// (Optional) when the immunization was given
//
@property (readwrite, nonatomic, strong) HVApproxDateTime* administeredDate;
//
// (Optional) who gave it
//
@property (readwrite, nonatomic, strong) HVPerson* administrator;
//
// (Optional) Immunization made by
// Vocabularies: vaccine-manufacturers-mvx (HL7)
//
@property (readwrite, nonatomic, strong) HVCodableValue* manufacturer;
//
// (Optional) Lot #
//
@property (readwrite, nonatomic, strong) NSString* lot;
//
// (Optional) how the immunization was given
// Vocabulary: immunization-routes
//
@property (readwrite, nonatomic, strong) HVCodableValue* route;
//
// (Optional) Expiration date
//
@property (readwrite, nonatomic, strong) HVApproxDate* expiration;
//
// (Optional) Sequence #
//
@property (readwrite, nonatomic, strong) NSString* sequence;
//
// (Optional) Where on the body the immunzation was given
// Vocabulary: immunization-anatomic-surface
//
@property (readwrite, nonatomic, strong) HVCodableValue* anatomicSurface;
//
// (Optional) Any adverse reaction to the immunization
// Vocabulary: immunization-adverse-effect
//
@property (readwrite, nonatomic, strong) NSString* adverseEvent;
//
// (Optional): Consent description
//
@property (readwrite, nonatomic, strong) NSString* consent;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithName:(NSString *) name;

+(HVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------

-(NSString *) toString;

//-------------------------
//
// Standard Vocabs
//
//-------------------------
+(HVVocabIdentifier *) vocabForName;

+(HVVocabIdentifier *) vocabForManufacturer;
+(HVVocabIdentifier *) vocabForAdverseEvent;
+(HVVocabIdentifier *) vocabForRoute;
+(HVVocabIdentifier *) vocabForSurface;

//-------------------------
//
// Type information
//
//-------------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

@end
