//
//  HVPersonalDemographics.h
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

@interface HVPersonalDemographics : HVItemDataTyped
{
@private
    HVName* m_name;
    HVDateTime* m_birthdate;
    HVCodableValue* m_bloodType;
    HVCodableValue* m_ethnicity;
    NSString* m_ssn;
    HVCodableValue* m_maritalStatus;
    NSString* m_employmentStatus;
    HVBool* m_isDeceased;
    HVApproxDateTime* m_dateOfDeath;
    HVCodableValue* m_religion;
    HVBool* m_veteran;
    HVCodableValue* m_education;
    HVBool* m_disabled;
    NSString* m_donor;
}

//-------------------------
//
// Data
//
//-------------------------
//
// ALL information is optional
//
@property (readwrite, nonatomic, strong) HVName* name;
@property (readwrite, nonatomic, strong) HVDateTime* birthDate;
@property (readwrite, nonatomic, strong) HVCodableValue* bloodType;
@property (readwrite, nonatomic, strong) HVCodableValue* ethnicity;
@property (readwrite, nonatomic, strong) NSString* ssn;
@property (readwrite, nonatomic, strong) HVCodableValue* maritalStatus;
@property (readwrite, nonatomic, strong) NSString* employmentStatus;
@property (readwrite, nonatomic, strong) HVBool* isDeceased;
@property (readwrite, nonatomic, strong) HVApproxDateTime* dateOfDeath;
@property (readwrite, nonatomic, strong) HVCodableValue* religion;
@property (readwrite, nonatomic, strong) HVBool* isVeteran;
@property (readwrite, nonatomic, strong) HVCodableValue* education;
@property (readwrite, nonatomic, strong) HVBool* isDisabled;
@property (readwrite, nonatomic, strong) NSString* organDonor;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;


-(NSString *) toString;

//-------------------------
//
// Vocab
//
//-------------------------
+(HVVocabIdentifier *) vocabForBloodType;
+(HVVocabIdentifier *) vocabForEthnicity;
+(HVVocabIdentifier *) vocabForMaritalStatus;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
