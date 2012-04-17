//
//  HVItemTypes.h
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

#import "HVWeight.h"
#import "HVBloodPressure.h"
#import "HVCholesterol.h"
#import "HVBloodGlucose.h"
#import "HVHeight.h"
#import "HVExercise.h"
#import "HVDailyMedicationUsage.h"
#import "HVEmotionalState.h"
#import "HVSleepJournalAM.h"
#import "HVSleepJournalPM.h"
#import "HVDietaryIntake.h"
#import "HVAllergy.h"
#import "HVCondition.h"
#import "HVImmunization.h"
#import "HVMedication.h"
#import "HVProcedure.h"
#import "HVVitalSigns.h"
#import "HVEncounter.h"
#import "HVFamilyHistory.h"
#import "HVEmergencyOrProviderContact.h"
#import "HVPersonalContactInfo.h"
#import "HVBasicDemographics.h"
#import "HVPersonalDemographics.h"
#import "HVAssessment.h"
#import "HVQuestionAnswer.h"
#import "HVItemRaw.h"

@interface HVItem (HVTypedExtensions)

-(HVItemDataTyped *) getDataOfType:(NSString *) typeID;

-(HVWeight *) weight;
-(HVBloodPressure *) bloodPressure;
-(HVCholesterol *) cholesterol;
-(HVBloodGlucose *) bloodGlucose;
-(HVHeight *) height;
-(HVExercise *) exercise;
-(HVDailyMedicationUsage *) medicationUsage;
-(HVEmotionalState *) emotionalState;
-(HVAssessment *) assessment;
-(HVQuestionAnswer *) questionAnswer;
-(HVDietaryIntake *) dietaryIntake;
-(HVSleepJournalAM *) sleepJournalAM;
-(HVSleepJournalPM *) sleepJournalPM;

-(HVAllergy *) allergy;
-(HVCondition *) condition;
-(HVImmunization *) immunization;
-(HVMedication *) medication;
-(HVProcedure *) procedure;
-(HVVitalSigns *) vitalSigns;
-(HVEncounter *) encounter;
-(HVFamilyHistory *) familyHistory;

-(HVEmergencyOrProviderContact *) emergencyOrProviderContact;
-(HVPersonalContactInfo *) personalContact;

-(HVBasicDemographics *) basicDemographics;
-(HVPersonalDemographics *) personalDemographics;

@end
