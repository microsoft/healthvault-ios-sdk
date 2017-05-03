//
//  HVItemTestExtensions.h
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
#import "HVItemTypes.h"
#import "HVSynchronizedStore.h"

//--------------------------
//
// Extensions that generate new HealthVault items
// with random, BUT VALID values. 
//
//--------------------------

NSDate* createRandomDate(void);
HVDateTime* createRandomHVDateTime(void);
HVDate* createRandomHVDate(void);
HVApproxDateTime* createRandomApproxHVDate(void);
NSString* pickRandomString(int count, ...);
NSString* pickRandomDrug(void);

@interface HVContact (HVTestExtensions)
+(HVContact *) createRandom;
@end

@interface HVPerson (HVTestExtensions)
+(HVPerson *) createRandom;
@end

@interface HVOrganization (HVTestExtensions)
+(HVOrganization *) createRandom;
@end

@interface HVWeightMeasurement (HVTestExtensions)

+(HVWeightMeasurement *) createRandomGramsMin:(NSUInteger) min max:(NSUInteger) max;

@end

@interface HVItem (HVTestExtensions)

+(HVItem *) createRandomOfClass:(NSString *) className;

@end

@interface HVWeight (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDateTime *) dateTime;
+(HVItem *) createRandomMetricForDate:(HVDateTime *) dateTime;

@end

@interface HVBloodPressure (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem*) createRandomForDate:(HVDateTime *) dateTime withPulse:(BOOL) pulse;

@end

@interface HVBloodGlucose (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem*) createRandomForDate:(HVDateTime *) dateTime;
+(HVItem *) createRandomMetricForDate:(HVDateTime *) dateTime;
+(HVItem*) createRandomForDate:(HVDateTime *) dateTime metric:(BOOL) metric;

@end

@interface HVCholesterolV2 (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDateTime *) dateTime;
+(HVItem *) createRandomMetricForDate:(HVDateTime *) dateTime;
+(HVItem *) createRandomForDate:(HVDateTime *) dateTime metric:(BOOL)metric;

@end

@interface HVHeartRate (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDateTime *) dateTime;

@end

@interface HVHeight (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVDailyDietaryIntake (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVDietaryIntake (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomValuesForFood:(HVCodableValue *) food meal:(HVCodableValue *) meal onDate:(HVDateTime *) date;

@end

@interface HVExercise (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVApproxDateTime *) date;
+(HVItem *) createRandomForDate:(HVApproxDateTime *) date metric:(BOOL)metric;

@end

@interface HVAllergy (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVCondition (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVMedication (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVApproxDateTime *) date;

@end

@interface HVImmunization (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVApproxDateTime *) date;

@end

@interface HVProcedure (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVApproxDateTime *) date;

@end

@interface HVVitalSigns (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVEncounter (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVFamilyHistory (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVAssessment (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVQuestionAnswer (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVEmergencyOrProviderContact (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVPersonalContactInfo (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVSleepJournalAM (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDateTime *) date withAwakenings:(BOOL) doAwakenings;

@end

@interface HVSleepJournalPM (HVTestExtensions)

+(HVItem *) createRandom;

@end

@interface HVEmotionalState (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDateTime *) date;

@end

@interface HVDailyMedicationUsage (HVTestExtensions)

+(HVItem *) createRandom;
+(HVItem *) createRandomForDate:(HVDate *) date;
+(HVItem *) createRandomForDate:(HVDate *) date forDrug:(NSString *) drug;
@end

@interface HVTestSynchronizedStore : HVSynchronizedStore

@property (readwrite, nonatomic) double failureProbability;

@end

