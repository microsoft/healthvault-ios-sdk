//
//  MHVItemTypes.m
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
#import "XLib.h"
#import "MHVItemTypes.h"
/*
#define HVDECLARE_GETTOR(type, name) \
-(type *) name { \
    if (self.hasTypedData) { \
            return (type *) self.data.typed; \
    } \
    return nil; \
}
*/

#define HVDECLARE_GETTOR(type, name) \
-(type *) name { \
    return (type *) [self getDataOfType:[type typeID]]; \
}


@implementation MHVItem (HVTypedExtensions)

-(MHVItemDataTyped *)getDataOfType:(NSString *)typeID
{
    if (!self.hasTypedData)
    {
        return nil;
    }
    
    HVASSERT([self.type.typeID isEqualToString:typeID]);
    return self.data.typed;
}

HVDECLARE_GETTOR(MHVWeight, weight);

HVDECLARE_GETTOR(MHVBloodPressure, bloodPressure);

HVDECLARE_GETTOR(MHVCholesterol, cholesterol);

HVDECLARE_GETTOR(MHVCholesterolV2, cholesterolV2);

HVDECLARE_GETTOR(MHVBloodGlucose, bloodGlucose);

HVDECLARE_GETTOR(MHVHeartRate, heartRate);

HVDECLARE_GETTOR(MHVPeakFlow, peakFlow);

HVDECLARE_GETTOR(MHVHeight, height);

HVDECLARE_GETTOR(MHVExercise, exercise);

HVDECLARE_GETTOR(MHVDailyMedicationUsage, medicationUsage);

HVDECLARE_GETTOR(MHVEmotionalState, emotionalState);

HVDECLARE_GETTOR(MHVAssessment, assessment);

HVDECLARE_GETTOR(MHVQuestionAnswer, questionAnswer);

HVDECLARE_GETTOR(MHVDailyDietaryIntake, dailyDietaryIntake);

HVDECLARE_GETTOR(MHVDietaryIntake, dietaryIntake);

HVDECLARE_GETTOR(MHVSleepJournalAM, sleepJournalAM);

HVDECLARE_GETTOR(MHVSleepJournalPM, sleepJournalPM);

HVDECLARE_GETTOR(MHVAllergy, allergy);

HVDECLARE_GETTOR(MHVCondition, condition);

HVDECLARE_GETTOR(MHVImmunization, immunization);

HVDECLARE_GETTOR(MHVMedication, medication);

HVDECLARE_GETTOR(MHVProcedure, procedure);

HVDECLARE_GETTOR(MHVVitalSigns, vitalSigns);

HVDECLARE_GETTOR(MHVEncounter, encounter);

HVDECLARE_GETTOR(MHVFamilyHistory, familyHistory);

HVDECLARE_GETTOR(MHVCCD, ccd);

HVDECLARE_GETTOR(MHVCCR, ccr);

HVDECLARE_GETTOR(MHVInsurance, insurance);

HVDECLARE_GETTOR(MHVMessage, message);

HVDECLARE_GETTOR(MHVLabTestResults, labResults);

HVDECLARE_GETTOR(MHVEmergencyOrProviderContact, emergencyOrProviderContact);

HVDECLARE_GETTOR(MHVPersonalContactInfo, personalContact);

HVDECLARE_GETTOR(MHVBasicDemographics, basicDemographics);

HVDECLARE_GETTOR(MHVPersonalDemographics, personalDemographics);

HVDECLARE_GETTOR(MHVPersonalImage, personalImage);

HVDECLARE_GETTOR(MHVFile, file);

@end
