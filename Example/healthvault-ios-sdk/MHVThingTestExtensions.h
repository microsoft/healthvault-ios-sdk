//
// MHVThingTestExtensions.h
// MHVTestLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVThingTypes.h"

// --------------------------
//
// Extensions that generate new HealthVault things
// with random, BUT VALID values.
//
// --------------------------

NSDate *createRandomDate(void);
MHVDateTime *createRandomMHVDateTime(void);
MHVDate *createRandomMHVDate(void);
MHVApproxDateTime *createRandomApproxMHVDate(void);
NSString *pickRandomString(int count, ...);
NSString *pickRandomDrug(void);

@interface MHVContact (MHVTestExtensions)
+ (MHVContact *)createRandom;
@end

@interface MHVPerson (MHVTestExtensions)
+ (MHVPerson *)createRandom;
@end

@interface MHVOrganization (MHVTestExtensions)
+ (MHVOrganization *)createRandom;
@end

@interface MHVWeightMeasurement (MHVTestExtensions)

+ (MHVWeightMeasurement *)createRandomGramsMin:(NSUInteger)min max:(NSUInteger)max;

@end

@interface MHVThing (MHVTestExtensions)

+ (MHVThing *)createRandomOfClass:(NSString *)className;

@end

@interface MHVWeight (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime;
+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime;

@end

@interface MHVBloodPressure (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime withPulse:(BOOL)pulse;

@end

@interface MHVBloodGlucose (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime;
+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric;

@end

@interface MHVCholesterol (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime;
+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric;

@end

@interface MHVHeartRate (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime;

@end

@interface MHVHeight (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVDailyDietaryIntake (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVDietaryIntake (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomValuesForFood:(MHVCodableValue *)food meal:(MHVCodableValue *)meal onDate:(MHVDateTime *)date;

@end

@interface MHVExercise (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date;
+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date metric:(BOOL)metric;

@end

@interface MHVAllergy (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVCondition (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVMedication (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date;

@end

@interface MHVImmunization (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date;

@end

@interface MHVProcedure (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date;

@end

@interface MHVVitalSigns (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVEncounter (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVFamilyHistory (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVAssessment (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVQuestionAnswer (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVEmergencyOrProviderContact (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVPersonalContactInfo (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVSleepJournalAM (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)date withAwakenings:(BOOL)doAwakenings;

@end

@interface MHVSleepJournalPM (MHVTestExtensions)

+ (MHVThing *)createRandom;

@end

@interface MHVEmotionalState (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDateTime *)date;

@end

@interface MHVDailyMedicationUsage (MHVTestExtensions)

+ (MHVThing *)createRandom;
+ (MHVThing *)createRandomForDate:(MHVDate *)date;
+ (MHVThing *)createRandomForDate:(MHVDate *)date forDrug:(NSString *)drug;
@end

