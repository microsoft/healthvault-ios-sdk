//
//  MHVItemTypes.h
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

#import "MHVWeight.h"
#import "MHVBloodPressure.h"
#import "MHVCholesterol.h"
#import "MHVBloodGlucose.h"
#import "MHVHeartRate.h"
#import "MHVHeight.h"
#import "MHVPeakFlow.h"
#import "MHVExercise.h"
#import "MHVDailyMedicationUsage.h"
#import "MHVEmotionalState.h"
#import "MHVSleepJournalAM.h"
#import "MHVSleepJournalPM.h"
#import "MHVDietaryIntake.h"
#import "MHVDailyDietaryIntake.h"
#import "MHVAllergy.h"
#import "MHVCondition.h"
#import "MHVImmunization.h"
#import "MHVMedication.h"
#import "MHVProcedure.h"
#import "MHVVitalSigns.h"
#import "MHVEncounter.h"
#import "MHVFamilyHistory.h"
#import "MHVCCD.h"
#import "MHVCCR.h"
#import "MHVInsurance.h"
#import "MHVEmergencyOrProviderContact.h"
#import "MHVPersonalContactInfo.h"
#import "MHVBasicDemographics.h"
#import "MHVPersonalDemographics.h"
#import "MHVPersonalImage.h"
#import "MHVAssessment.h"
#import "MHVQuestionAnswer.h"
#import "MHVFile.h"
#import "MHVMessage.h"
#import "MHVLabTestResults.h"
#import "MHVItemRaw.h"

@interface MHVItem (MHVTypedExtensions)

-(MHVItemDataTyped *) getDataOfType:(NSString *) typeID;

-(MHVWeight *) weight;
-(MHVBloodPressure *) bloodPressure;
-(MHVCholesterol *) cholesterol;
-(MHVBloodGlucose *) bloodGlucose;
-(MHVHeight *) height;
-(MHVHeartRate *) heartRate;
-(MHVPeakFlow *) peakFlow;
-(MHVExercise *) exercise;
-(MHVDailyMedicationUsage *) medicationUsage;
-(MHVEmotionalState *) emotionalState;
-(MHVAssessment *) assessment;
-(MHVQuestionAnswer *) questionAnswer;
-(MHVDailyDietaryIntake *) dailyDietaryIntake;
-(MHVDietaryIntake *) dietaryIntake;
-(MHVSleepJournalAM *) sleepJournalAM;
-(MHVSleepJournalPM *) sleepJournalPM;

-(MHVAllergy *) allergy;
-(MHVCondition *) condition;
-(MHVImmunization *) immunization;
-(MHVMedication *) medication;
-(MHVProcedure *) procedure;
-(MHVVitalSigns *) vitalSigns;
-(MHVEncounter *) encounter;
-(MHVFamilyHistory *) familyHistory;
-(MHVCCD *) ccd;
-(MHVCCR *) ccr;
-(MHVInsurance *) insurance;
-(MHVMessage *) message;
-(MHVLabTestResults *) labResults;

-(MHVEmergencyOrProviderContact *) emergencyOrProviderContact;
-(MHVPersonalContactInfo *) personalContact;

-(MHVBasicDemographics *) basicDemographics;
-(MHVPersonalDemographics *) personalDemographics;
-(MHVPersonalImage *) personalImage;

-(MHVFile *) file;

@end
