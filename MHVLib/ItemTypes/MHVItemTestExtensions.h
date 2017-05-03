//
//  MHVItemTestExtensions.h
//  HVTestLib
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
//
#import <Foundation/Foundation.h>
#import "MHVItemTypes.h"
#import "MHVSynchronizedStore.h"

//--------------------------
//
// Extensions that generate new HealthVault items
// with random, BUT VALID values. 
//
//--------------------------

NSDate* createRandomDate(void);
MHVDateTime* createRandomMHVDateTime(void);
MHVDate* createRandomMHVDate(void);
MHVApproxDateTime* createRandomApproxMHVDate(void);
NSString* pickRandomString(int count, ...);
NSString* pickRandomDrug(void);

@interface MHVContact (HVTestExtensions)
+(MHVContact *) createRandom;
@end

@interface MHVPerson (HVTestExtensions)
+(MHVPerson *) createRandom;
@end

@interface MHVOrganization (HVTestExtensions)
+(MHVOrganization *) createRandom;
@end

@interface MHVWeightMeasurement (HVTestExtensions)

+(MHVWeightMeasurement *) createRandomGramsMin:(NSUInteger) min max:(NSUInteger) max;

@end

@interface MHVItem (HVTestExtensions)

+(MHVItem *) createRandomOfClass:(NSString *) className;

@end

@interface MHVWeight (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;

@end

@interface MHVBloodPressure (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime withPulse:(BOOL) pulse;

@end

@interface MHVBloodGlucose (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime metric:(BOOL) metric;

@end

@interface MHVCholesterolV2 (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime metric:(BOOL)metric;

@end

@interface MHVHeartRate (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;

@end

@interface MHVHeight (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVDailyDietaryIntake (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVDietaryIntake (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomValuesForFood:(MHVCodableValue *) food meal:(MHVCodableValue *) meal onDate:(MHVDateTime *) date;

@end

@interface MHVExercise (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date metric:(BOOL)metric;

@end

@interface MHVAllergy (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVCondition (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVMedication (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVImmunization (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVProcedure (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVVitalSigns (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEncounter (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVFamilyHistory (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVAssessment (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVQuestionAnswer (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEmergencyOrProviderContact (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVPersonalContactInfo (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVSleepJournalAM (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) date withAwakenings:(BOOL) doAwakenings;

@end

@interface MHVSleepJournalPM (HVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEmotionalState (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) date;

@end

@interface MHVDailyMedicationUsage (HVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDate *) date;
+(MHVItem *) createRandomForDate:(MHVDate *) date forDrug:(NSString *) drug;
@end

@interface MHVTestSynchronizedStore : MHVSynchronizedStore

@property (readwrite, nonatomic) double failureProbability;

@end

