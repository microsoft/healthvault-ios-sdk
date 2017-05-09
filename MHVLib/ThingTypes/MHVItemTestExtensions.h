//
//  MHVItemTestExtensions.h
//  MHVTestLib
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

@interface MHVContact (MHVTestExtensions)
+(MHVContact *) createRandom;
@end

@interface MHVPerson (MHVTestExtensions)
+(MHVPerson *) createRandom;
@end

@interface MHVOrganization (MHVTestExtensions)
+(MHVOrganization *) createRandom;
@end

@interface MHVWeightMeasurement (MHVTestExtensions)

+(MHVWeightMeasurement *) createRandomGramsMin:(NSUInteger) min max:(NSUInteger) max;

@end

@interface MHVItem (MHVTestExtensions)

+(MHVItem *) createRandomOfClass:(NSString *) className;

@end

@interface MHVWeight (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;

@end

@interface MHVBloodPressure (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime withPulse:(BOOL) pulse;

@end

@interface MHVBloodGlucose (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;
+(MHVItem*) createRandomForDate:(MHVDateTime *) dateTime metric:(BOOL) metric;

@end

@interface MHVCholesterol (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomMetricForDate:(MHVDateTime *) dateTime;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime metric:(BOOL)metric;

@end

@interface MHVHeartRate (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;

@end

@interface MHVHeight (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVDailyDietaryIntake (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVDietaryIntake (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomValuesForFood:(MHVCodableValue *) food meal:(MHVCodableValue *) meal onDate:(MHVDateTime *) date;

@end

@interface MHVExercise (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date metric:(BOOL)metric;

@end

@interface MHVAllergy (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVCondition (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVMedication (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVImmunization (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVProcedure (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVApproxDateTime *) date;

@end

@interface MHVVitalSigns (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEncounter (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVFamilyHistory (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVAssessment (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVQuestionAnswer (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEmergencyOrProviderContact (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVPersonalContactInfo (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVSleepJournalAM (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) date withAwakenings:(BOOL) doAwakenings;

@end

@interface MHVSleepJournalPM (MHVTestExtensions)

+(MHVItem *) createRandom;

@end

@interface MHVEmotionalState (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDateTime *) date;

@end

@interface MHVDailyMedicationUsage (MHVTestExtensions)

+(MHVItem *) createRandom;
+(MHVItem *) createRandomForDate:(MHVDate *) date;
+(MHVItem *) createRandomForDate:(MHVDate *) date forDrug:(NSString *) drug;
@end

@interface MHVTestSynchronizedStore : MHVSynchronizedStore

@property (readwrite, nonatomic) double failureProbability;

@end

