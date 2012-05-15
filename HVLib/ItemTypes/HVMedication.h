//
//  HVMedication.h
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"
#import "HVVocab.h"


@interface HVMedication : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVCodableValue* m_genericName;
    HVApproxMeasurement* m_dose;
    HVApproxMeasurement* m_strength;
    HVApproxMeasurement* m_freq;
    HVCodableValue* m_route;
    HVCodableValue* m_indication;
    HVApproxDateTime* m_startDate;
    HVApproxDateTime* m_stopDate;
    HVCodableValue* m_prescribed;
    HVPrescription* m_prescription;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) Medication Name
// Vocabularies: RxNorm, NDC
//
@property (readwrite, nonatomic, retain) HVCodableValue* name;
//
// (Optional)
// Vocabularies: RxNorm, NDC
//
@property (readwrite, nonatomic, retain) HVCodableValue* genericName;
// 
// (Optional)
// Vocabulary for Units: medication-dose-units
//
@property (readwrite, nonatomic, retain) HVApproxMeasurement* dose;
// 
// (Optional)
// Vocabulary for Units: medication-strength-unit
//
@property (readwrite, nonatomic, retain) HVApproxMeasurement* strength;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxMeasurement* frequency;
// 
// (Optional)
// Vocabulary for Units: medication-route
//
@property (readwrite, nonatomic, retain) HVCodableValue* route;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* indication;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* startDate;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* stopDate;
// 
// (Optional) Was the medication prescribed? 
// Vocabulary: medication-prescribed
//
@property (readwrite, nonatomic, retain) HVCodableValue* prescribed;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVPrescription* prescription;

//
// Convenience Properties
//
@property (readonly, nonatomic) HVPerson* prescriber;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithName:(NSString *) name;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
+(HVItem *) newItem;

//-------------------------
//
// Standard Vocabularies
//
//-------------------------
+(HVVocabIdentifier *) vocabForName;  // RxNorm active medications

+(HVVocabIdentifier *) vocabForDoseUnits;
+(HVVocabIdentifier *) vocabForStrengthUnits;
+(HVVocabIdentifier *) vocabForRoute;
+(HVVocabIdentifier *) vocabForIsPrescribed;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
