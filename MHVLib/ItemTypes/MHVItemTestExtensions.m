//
//  MHVItemTestExtensions.m
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

#import "MHVCommon.h"
#import "MHVRandom.h"
#import "MHVItemTestExtensions.h"

NSDate* createRandomDate(void)
{
    return [MHVRandom newRandomDayOffsetFromTodayInRangeMin:0 max:-365];
}

MHVDateTime* createRandomMHVDateTime(void)
{
    return [MHVDateTime fromDate:createRandomDate()];
}

MHVDate* createRandomMHVDate(void)
{
    return [[MHVDate alloc] initWithDate:createRandomDate()]; 
}

MHVApproxDateTime* createRandomApproxMHVDate(void)
{
    return [[MHVApproxDateTime alloc] initWithDateTime:createRandomMHVDateTime()];
}

NSString* pickRandomString(int count, ...)
{
    va_list args;
    va_start(args, count);
    NSString* retVal = nil;
    
    int randomIndex = [MHVRandom randomIntInRangeMin:0 max:count - 1];
    if (randomIndex >= 0 && randomIndex < count)
    {
        for (int i = 0; i < count; ++i)
        {
            NSString *string = va_arg(args, NSString *);
            if (i == randomIndex)
            {
                retVal = string;
              }
         }
    }
        
    va_end(args);
    return retVal;
}

NSString* pickRandomDrug(void)
{
    return pickRandomString(8, @"Lipitor", @"Ibuprofen", @"Celebrex", @"Prozac", @"Claritin", @"Viagra", @"Omega 3 Supplement", @"Multi-vitamins");
}

@implementation MHVContact (HVTestExtensions)

+(MHVContact *)createRandom
{
    MHVContact* contact = [[MHVContact alloc] init];
    
    MHVAddress* address = [[MHVAddress alloc] init];
    [address.street addObject:@"1234 Princess Street"];
    address.city = @"Edinburgh";
    address.postalCode = @"ABCDEF";
    address.country = @"Scotland";
    
    MHVEmail* email = [[MHVEmail alloc] initWithEmailAddress:@"foo@bar.xyz"];
    MHVPhone* phone = [[MHVPhone alloc] initWithNumber:@"555-555-5555"];
    
    [contact.address addObject:address];
    [contact.email addObject:email];
    [contact.phone addObject:phone];
    
    return contact;
}

@end

@implementation MHVPerson (HVTestExtensions)

+(MHVPerson *) createRandom
{
    MHVPerson* person = [[MHVPerson alloc] init];
    
    person.name = [[MHVName alloc] initWithFirst:@"Toby" middle:@"R." andLastName:@"McDuff"];
    person.organization = @"Justice League of Doctors";
    person.training = @"MD, Phd., AB, FRCS, PQRS, XYZ";
    
    person.contact = [MHVContact createRandom];
    
    return person;
}

@end

@implementation MHVOrganization (HVTestExtensions)

+(MHVOrganization *)createRandom
{
    MHVOrganization* org = [[MHVOrganization alloc] init];
    org.name = @"Toto Memorial Hospital";
    org.contact = [MHVContact createRandom];
    org.website = @"http://www.bing.com";
    
    return org;
}

@end

@implementation MHVWeightMeasurement (HVTestExtensions)

+(MHVWeightMeasurement *)createRandomGramsMin:(NSUInteger)min max:(NSUInteger)max
{
    int value = [MHVRandom randomIntInRangeMin:(int)min max:(int)max];
    if (value <= 0)
    {
        return nil;
    }
    
    return [MHVWeightMeasurement fromGrams:value];
}

@end

@implementation MHVItem (HVTestExtensions)

+(MHVItem *)createRandomOfClass:(NSString *)className
{
    Class cls = NSClassFromString(className);
    if (cls == nil)
    {
        return nil;
    }
    
    @try {
        return (MHVItem *) [cls createRandom];
    }
    @catch (NSException *exception) 
    {
    }
    
    return nil;
}

@end

@implementation MHVWeight (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVWeight createRandomForDate:createRandomMHVDateTime()];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime
{
    MHVItem *item = [MHVWeight newItem];
    item.weight.when = dateTime;
    
    double pounds = [MHVRandom randomDoubleInRangeMin:120 max:145];
    pounds = roundToPrecision(pounds, 1);
    item.weight.inPounds = pounds;
    
    return item;    
}

+(MHVItem *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    MHVItem *item = [MHVWeight newItem];
    item.weight.when = dateTime;
    
    double kg = [MHVRandom randomDoubleInRangeMin:50 max:75];
    kg = roundToPrecision(kg, 1);
    item.weight.inKg = kg;
    
    return item;
}

@end

@implementation MHVBloodPressure (HVTestExtensions)
    
+(MHVItem *)createRandom
{
    return [MHVBloodPressure createRandomForDate:createRandomMHVDateTime() withPulse:FALSE];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime withPulse:(BOOL)pulse
{
    MHVItem *item = [MHVBloodPressure newItem];
    MHVBloodPressure *bp = item.bloodPressure;
    
    bp.when = dateTime;
    
    int s = [MHVRandom randomIntInRangeMin:120 max:150];
    int d = s - [MHVRandom randomIntInRangeMin:25 max:40];
    
    bp.systolicValue = s;
    bp.diastolicValue = d;
    
    if (pulse)
    {
        bp.pulseValue = [MHVRandom randomIntInRangeMin:60 max:100];
    }
    
    return item;
}

@end

@implementation MHVBloodGlucose (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVBloodGlucose createRandomForDate:createRandomMHVDateTime()];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime
{
    return [MHVBloodGlucose createRandomForDate:dateTime metric:FALSE];
}

+(MHVItem *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    return [MHVBloodGlucose createRandomForDate:dateTime metric:TRUE];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric
{
    MHVItem* item = [MHVBloodGlucose newItem];
    MHVBloodGlucose* glucose = item.bloodGlucose;
    glucose.when = dateTime;
    
    if (metric)
    {
        double mmol = [MHVRandom randomDoubleInRangeMin:3 max:6];
        mmol = roundToPrecision(mmol, 1);
        glucose.inMmolPerLiter = mmol;
    }
    else
    {
        glucose.inMgPerDL = [MHVRandom randomIntInRangeMin:75 max:110];        
    }
    
    glucose.measurementType = [MHVBloodGlucose createWholeBloodMeasurementType];
    
    glucose.isOutsideOperatingTemp = FALSE;
    
    [item updateEndDate:[dateTime toDate]];
    
    return item;
    
}

@end

@implementation MHVCholesterolV2 (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVCholesterolV2 createRandomForDate:createRandomMHVDateTime()];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime
{
    return [MHVCholesterolV2 createRandomForDate:dateTime metric:FALSE];
}

+(MHVItem *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    return [MHVCholesterolV2 createRandomForDate:dateTime metric:TRUE];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric
{
    MHVItem* item = [MHVCholesterolV2 newItem];
    MHVCholesterolV2* cholesterol = item.cholesterolV2;
    
    cholesterol.when = dateTime;
    if (metric)
    {
        cholesterol.ldlValue = roundToPrecision([MHVRandom randomDoubleInRangeMin:3 max:5], 2);
        cholesterol.hdlValue = roundToPrecision([MHVRandom randomDoubleInRangeMin:1 max:2.5], 2);
        cholesterol.triglyceridesValue = roundToPrecision([MHVRandom randomDoubleInRangeMin:2 max:3], 2);
        cholesterol.totalValue = roundToPrecision(cholesterol.ldlValue + cholesterol.hdlValue + cholesterol.triglyceridesValue / 5, 2);
    }
    else
    {
        cholesterol.ldlValueMgDL = [MHVRandom randomIntInRangeMin:80 max:130];
        cholesterol.hdlValueMgDL = [MHVRandom randomIntInRangeMin:30 max:60];
        cholesterol.triglyceridesValueMgDl = [MHVRandom randomIntInRangeMin:150 max:250];
        cholesterol.totalValueMgDL = cholesterol.ldlValueMgDL +
                                    cholesterol.hdlValueMgDL +
                                    (int)(cholesterol.triglyceridesValueMgDl / 5);
    }
    
    return item;    
}

@end

@implementation MHVHeartRate (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVHeartRate createRandomForDate:createRandomMHVDateTime()];
}

+(MHVItem *) createRandomForDate:(MHVDateTime *) dateTime;
{
    MHVItem* item = [MHVHeartRate newItem];
    MHVHeartRate* heartRate = item.heartRate;
    
    heartRate.when = dateTime;
    heartRate.bpmValue = [MHVRandom randomIntInRangeMin:60 max:140];
    
    return item;
    
}
@end

@implementation MHVHeight (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVHeight newItem];
    MHVHeight* height = item.height;
    
    height.when = createRandomMHVDateTime();
    height.inInches = [MHVRandom randomIntInRangeMin:12 max:84];
    
    return item;
}

@end

@implementation MHVDailyDietaryIntake (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVDailyDietaryIntake newItem];
    MHVDailyDietaryIntake* diet = item.dailyDietaryIntake;
    
    diet.when = createRandomMHVDate();
    diet.caloriesValue = [MHVRandom randomIntInRangeMin:1800 max:3000];
    diet.totalFatGrams = [MHVRandom randomDoubleInRangeMin:0 max:100];
    diet.saturatedFatGrams = [MHVRandom randomDoubleInRangeMin:0 max:diet.totalFatGrams];
    diet.proteinGrams = [MHVRandom randomDoubleInRangeMin:1 max:100];
    diet.sugarGrams = [MHVRandom randomDoubleInRangeMin:10 max:400];
    diet.dietaryFiberGrams = [MHVRandom randomDoubleInRangeMin:1 max:100];
    diet.totalCarbGrams = diet.dietaryFiberGrams + diet.sugarGrams + [MHVRandom randomDoubleInRangeMin:10 max:400];
    diet.cholesterolMilligrams = [MHVRandom randomDoubleInRangeMin:0 max:100];
    
    return item;
}

@end

@implementation MHVExercise (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVExercise createRandomForDate:createRandomApproxMHVDate()];
}

+(MHVItem *)createRandomForDate:(MHVApproxDateTime *)date
{
    return [MHVExercise createRandomForDate:date metric:FALSE];
}

+(MHVItem *)createRandomForDate:(MHVApproxDateTime *) date metric:(BOOL)metric
{
    MHVItem* item = [MHVExercise newItem];
    MHVExercise* exercise = item.exercise;
    
    exercise.when = date;
    
    NSString* activity = pickRandomString(3, @"Aerobics", @"Walking", @"Running");
    [exercise setStandardActivity:activity];
    
    exercise.durationMinutesValue = [MHVRandom randomIntInRangeMin:15 max:45];
    
    double distance = 0;
    double stepCount = 0;
    double caloriesBurned = 0;
    if ([activity isEqualToString:@"Walking"])
    {
        stepCount = exercise.durationMinutesValue * 100;  // 100 steps per minute
        caloriesBurned = exercise.durationMinutesValue * 5; // 5 calories per minute
        if (metric)
        {
            distance = exercise.durationMinutesValue / 10; // 10 minutes per KM
        }
        else
        {
            distance = exercise.durationMinutesValue / 15; // 15 minute miles
        }
    }
    else if ([activity isEqualToString:@"Running"])
    {
        stepCount = exercise.durationMinutesValue * 200;  // 300 steps per minute
        caloriesBurned = exercise.durationMinutesValue * 10; // 10 calories per minute
        if (metric)
        {
            distance = exercise.durationMinutesValue / 5; // 5 min KMs
        }
        else
        {
            distance = exercise.durationMinutesValue / 7.5; // 7.5 minute miles
        }
    }
    else
    {
        stepCount = exercise.durationMinutesValue * 50;  // 50 steps per minute
        caloriesBurned = exercise.durationMinutesValue * 10; // 10 calories per minute
    }

    MHVCodedValue* detailCode;
    MHVMeasurement* measurement;
    if (distance > 0)
    {
        distance = roundToPrecision(distance, 1);
        if (metric)
        {
            exercise.distance = [MHVLengthMeasurement fromKilometers:distance];
        }
        else
        {
            exercise.distance = [MHVLengthMeasurement fromMiles:distance];
        }
    }
    if (stepCount > 0)
    {
        measurement = [MHVExercise measurementForCount:stepCount]; 
        //
        // Simulate Fitbit bug occasionally
        //
        if ([MHVRandom randomDouble] <= 0.2)
        {
            detailCode = [MHVExercise detailNameWithCode:@"Number of steps"];
        }
        else
        {
            detailCode = [MHVExercise detailNameForSteps];
        }

        MHVNameValue* details = [MHVNameValue fromName:detailCode andValue:measurement];
        [exercise.details addOrUpdate:details];
    }

    if (caloriesBurned > 0)
    {
         measurement = [MHVExercise measurementForCalories:caloriesBurned];
        //
        // Simulate Fitbit bug occasionally
        //
        if ([MHVRandom randomDouble] <= 0.2)
        {
            detailCode = [MHVExercise detailNameWithCode:@"Calories burned"];
        }
        else
        {
            detailCode = [MHVExercise detailNameForCaloriesBurned];
        }

        MHVNameValue* details = [MHVNameValue fromName:detailCode andValue:measurement];
        [exercise.details addOrUpdate:details];
    }
    
    return item;
}

@end

@implementation MHVAllergy (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVAllergy newItem];
    MHVAllergy* allergy = item.allergy;
    
    NSString* allergen = pickRandomString(3, @"Pollen", @"Peanuts", @"Penicillin");
    NSString* onset = pickRandomString(3, @"High School", @"As a child", @"Can't remember");
    
    allergy.name = [MHVCodableValue fromText:[NSString stringWithFormat:@"Allergy to %@", allergen]];
    allergy.firstObserved = [MHVApproxDateTime fromDescription:onset];
    if ([allergen isEqualToString:@"Pollen"])
    {
        allergy.allergenType = [MHVCodableValue fromText:@"environmental"];
        allergy.reaction = [MHVCodableValue fromText:@"sneezing"];
    }
    else if ([allergen isEqualToString:@"Peanuts"])
    {
        allergy.allergenType = [MHVCodableValue fromText:@"food"];
        allergy.reaction = [MHVCodableValue fromText:@"anaphylactic shock"];
    }
    else 
    {
        allergy.allergenType = [MHVCodableValue fromText:@"medication"];
        allergy.reaction = [MHVCodableValue fromText:@"anaphylactic shock"];
    }
    
    return item;
}

@end

@implementation MHVCondition (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVCondition newItem];
    MHVCondition* condition = item.condition;
    
    NSString* conditionName = pickRandomString(5, @"Migraine", @"Pancreatitis", @"Mild Depression", @"Ulcer", @"Endometriosis");
    condition.name = [MHVCodableValue fromText:conditionName];
    condition.status = [MHVCodableValue fromText:pickRandomString(2, @"chronic", @"acute")];
    
    if ([MHVRandom randomDouble] > 0.5)
    {
        condition.onsetDate = [MHVApproxDateTime fromDescription:@"As a teenager"];
    }
    else 
    {
        condition.onsetDate = createRandomApproxMHVDate();
    }
 
    return item;
}

@end

@implementation MHVMedication (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVMedication createRandomForDate:createRandomApproxMHVDate()];
}

+(MHVItem *)createRandomForDate:(MHVApproxDateTime *)date
{
    MHVItem* item = [MHVMedication newItem];
    MHVMedication* medication = item.medication;
    
    NSString* medicationName = pickRandomDrug();
    
    medication.name = [MHVCodableValue fromText:medicationName];
    medication.dose = [MHVApproxMeasurement fromValue:[MHVRandom randomIntInRangeMin:1 max:4]
                                           unitsText:@"Tablets" unitsCode:@"Tablets" unitsVocab:@"medication-dose-units"];
    medication.strength = [MHVApproxMeasurement fromValue:[MHVRandom randomIntInRangeMin:100 max:1000]
                                               unitsText:@"Milligrams" unitsCode:@"mg" unitsVocab:@"medication-strength-unit"];
    medication.frequency = [MHVApproxMeasurement fromDisplayText:pickRandomString(3, @"Once a day", @"Twice a day", @"As needed")];
    
    medication.startDate = date;
    
    return item;    
}

@end

@implementation MHVImmunization (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVApproxDateTime* date = nil;
    if ([MHVRandom randomDouble] > 0.5)
    {
        date = [MHVApproxDateTime fromDescription:@"As an adult"];
    }
    else
    {
        date = createRandomApproxMHVDate();
    }
    
    return [MHVImmunization createRandomForDate:date];
}

+(MHVItem *)createRandomForDate:(MHVApproxDateTime *)date
{
    MHVItem* item = [MHVImmunization newItem];
    MHVImmunization* immunization = item.immunization;
    
    immunization.administeredDate = date;

    if ([MHVRandom randomDouble] > 0.5)
    {
        immunization.name = [MHVCodableValue fromText:@"hepatitis A and hepatitis B vaccine" code:@"104" andVocab:@"vaccines-cvx"];
    }
    else
    {
        immunization.name = [MHVCodableValue fromText:@"influenza virus vaccine, whole virus" code:@"16" andVocab:@"vaccines-cvx"];
    }
    immunization.name.codes.firstCode.vocabularyFamily = @"HL7";
    immunization.name.codes.firstCode.vocabularyVersion = @"2.3 09_2008";
        
    if ([MHVRandom randomDouble] > 0.5)
    {
        immunization.manufacturer = [MHVCodableValue fromText:@"Merck & Co., Inc." code:@"MSD" andVocab:@"vaccine-manufacturers-mvx"];
    }
    else
    {
        immunization.manufacturer = [MHVCodableValue fromText:@"GlaxoSmithKline" code:@"SKB" andVocab:@"vaccine-manufacturers-mvx"];
    }
    
    immunization.lot = [NSString stringWithFormat:@"%d", [MHVRandom randomIntInRangeMin:5000 max:20000]];
    immunization.route = [MHVCodableValue fromText:@"Injected"];
    
    immunization.anatomicSurface = [MHVCodableValue fromText:@"Right arm"];
    
    return item;
}

@end

@implementation MHVProcedure (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVProcedure createRandomForDate:createRandomApproxMHVDate()];;
}

+(MHVItem *)createRandomForDate:(MHVApproxDateTime *) date
{
    MHVItem* item = [MHVProcedure newItem];
    MHVProcedure* procedure = item.procedure;
    
    procedure.name = [MHVCodableValue fromText:pickRandomString(3, @"eye surgery", @"root canal", @"colonoscopy")];
    procedure.when = date;
    procedure.primaryProvider = [MHVPerson createRandom];
    
    return item;
}
@end

@implementation MHVVitalSigns (HVTestExtensions)

+(MHVItem *) createRandom
{
    MHVItem* item = [MHVVitalSigns newItem];
    MHVVitalSigns* vitals = item.vitalSigns;
    
    double temperature = [MHVRandom randomDoubleInRangeMin:97 max:103];
    long temp = (long) (temperature * 10);
    temperature = ((double) temp) * 0.1;
    
    MHVVitalSignResult* result = [[MHVVitalSignResult alloc] initWithTemperature:temperature inCelsius:FALSE];
    
    vitals.when = createRandomMHVDateTime();
    [vitals.results addObject:result];
    
    return item;
}

@end

@implementation MHVEncounter (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVEncounter newItem];
    MHVEncounter* encounter = item.encounter;
    
    encounter.when = createRandomMHVDateTime();
    encounter.encounterType = [MHVCodableValue fromText:pickRandomString(3, @"Checkup Examination", @"Dental Procedures", @"Acute care")];
    encounter.duration = [[MHVDuration alloc] initWithDate:[encounter.when toDate] andDurationInSeconds:3600];
    encounter.facility = [MHVOrganization createRandom];
    
    return item;
}

@end

@implementation MHVFamilyHistory (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVRelative* relative = [[MHVRelative alloc] initWithRelationship:pickRandomString(4, @"Mother", @"Father", @"Grandmother", @"Grandfather")];
    MHVConditionEntry* condition = [[MHVConditionEntry alloc] initWithName:pickRandomString(4, @"Cancer", @"Heart Disease", @"Diabetes", @"Alzheimers")];
    
    MHVFamilyHistory* history = [[MHVFamilyHistory alloc] initWithRelative:relative andCondition:condition];
    
    return [[MHVItem alloc] initWithTypedData:history];
}

@end

@implementation MHVAssessment (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVAssessment newItem];
    MHVAssessment* assessment = item.assessment;
    
    assessment.when = createRandomMHVDateTime();
    assessment.category = [MHVCodableValue fromText:@"Self Assessment"];
    assessment.name = pickRandomString(3, @"Stress Assessment", @"Aerobic Fitness", @"Mental Fitness");
    [assessment.results addObject:[MHVAssessmentField from:@"Status" andValue:pickRandomString(2, @"Good", @"Bad")]];
    [assessment.results addObject:[MHVAssessmentField from:@"Needs Help" andValue:pickRandomString(2, @"Yes", @"No")]];

    return item;
}

@end

@implementation MHVQuestionAnswer (HVTestExtensions)

+(MHVItem *)createRandom
{
    int number = [MHVRandom randomIntInRangeMin:1 max:100];
    NSString* question = [NSString stringWithFormat:@"Question %d ?", number];
    NSString* answer = [NSString stringWithFormat:@"Answer to %d", number];
    
    MHVQuestionAnswer* qa = [[MHVQuestionAnswer alloc] initWithQuestion:question answer:answer andDate:createRandomDate()];
    
    return [[MHVItem alloc] initWithTypedData:qa];
}

@end

@implementation MHVEmergencyOrProviderContact (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVPerson* person;
    
    if ([MHVRandom randomDouble] > 0.5)
    {
        person = [[MHVPerson alloc] initWithFirstName:@"Bingo" lastName:@"Little" phone:@"555-555-0000" andEmail:@"bingo@little.pqr"];
    }
    else 
    {
        person = [[MHVPerson alloc] initWithName:@"Toby R. McDuff" phone:@"555-555-1111" andEmail:@"toby@mcduff.pqr"];
    }
    person.type = [MHVCodableValue fromText:@"Provider"];
    MHVEmergencyOrProviderContact* contact = [[MHVEmergencyOrProviderContact alloc] initWithPerson:person];
    return [[MHVItem alloc] initWithTypedData:contact];
}

@end

@implementation MHVPersonalContactInfo (HVTestExtensions)

+(MHVItem *) createRandom
{
    MHVItem* item = [MHVPersonalContactInfo newItem];
    MHVPersonalContactInfo* personalContact = item.personalContact;
    
    personalContact.contact = [MHVContact createRandom];
    
    return item;
}

@end

@implementation MHVSleepJournalAM (HVTestExtensions)

+(MHVItem *) createRandom
{
    return [MHVSleepJournalAM createRandomForDate:createRandomMHVDateTime() withAwakenings:TRUE];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)date withAwakenings:(BOOL)doAwakenings
{
    MHVItem* item = [MHVSleepJournalAM newItem];
    MHVSleepJournalAM* journal = item.sleepJournalAM;
    
    date.time = nil; // Don't bother noting down the time. Date is enough 
    journal.when = date;
    
    MHVTime* bedtime = [MHVTime fromHour:[MHVRandom randomIntInRangeMin:22 max:23] andMinute:[MHVRandom randomIntInRangeMin:1 max:59]];
    
    journal.bedTime = bedtime;
    journal.settlingMinutesValue = [MHVRandom randomIntInRangeMin:5 max:30];
    journal.sleepMinutesValue = [MHVRandom randomIntInRangeMin:180 max:360];
    
    int awakeMinutes =  [MHVRandom randomIntInRangeMin:0 max:55];
    if (awakeMinutes > 0 && doAwakenings)
    {
        MHVOccurence* awakening = [MHVOccurence forDuration:awakeMinutes atHour:((bedtime.hour) + 2) % 24 andMinute:bedtime.minute];
        [journal.awakenings addObject:awakening];
    }
    int bedMinutes = journal.settlingMinutesValue + journal.sleepMinutesValue + [MHVRandom randomIntInRangeMin:5 max:55];
    
    int wakeupHour = (journal.bedTime.hour + (bedMinutes / 60)) % 24;
    MHVTime* wakeTime = [MHVTime fromHour:wakeupHour andMinute:bedMinutes % 60];
    
    journal.wakeTime = wakeTime;
    
    journal.wakeState = (enum HVWakeState) [MHVRandom randomIntInRangeMin:1 max:3];
    
    return item;    
}

@end

@implementation MHVSleepJournalPM (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVItem* item = [MHVSleepJournalPM newItem];
    MHVSleepJournalPM* journal = item.sleepJournalPM;
    
    journal.when = createRandomMHVDateTime();
    journal.sleepiness = (enum HVSleepiness) [MHVRandom randomIntInRangeMin:1 max:4];
    
    for (int i = 0, count = [MHVRandom randomIntInRangeMin:3 max:5]; i < count; ++i)
    {
        MHVTime* time = [MHVTime fromHour:[MHVRandom randomIntInRangeMin:7 max:20] andMinute:[MHVRandom randomIntInRangeMin:1 max:59]];
        [journal.caffeineIntakeTimes addObject:time];        
    }
                                                                                    
    return item;
}

@end

@implementation MHVEmotionalState (HVTestExtensions)

+(MHVItem *)createRandom
{
    return [MHVEmotionalState createRandomForDate:createRandomMHVDateTime()];
}

+(MHVItem *)createRandomForDate:(MHVDateTime *)date
{
    MHVItem* item = [MHVEmotionalState newItem];
    MHVEmotionalState* es = item.emotionalState;
    
    es.when = date;
    
    int randInt;
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.stress = (enum HVRelativeRating) randInt;
    }
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.mood = (enum HVMood) randInt;
    }
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.wellbeing = (enum HVWellBeing) randInt;
    }
    
    return item;
}

@end

@implementation MHVDailyMedicationUsage (HVTestExtensions)

+(MHVItem *)createRandom
{
    NSDate* date = createRandomDate();
    return [MHVDailyMedicationUsage createRandomForDate:[MHVDate fromDate:date]];
}

+(MHVItem *)createRandomForDate:(MHVDate *)date
{
    NSString* drugName = pickRandomDrug();
    return [MHVDailyMedicationUsage createRandomForDate:date forDrug:drugName];
}

+(MHVItem *)createRandomForDate:(MHVDate *)date forDrug:(NSString *)drug
{
    MHVDailyMedicationUsage* usage = [[MHVDailyMedicationUsage alloc]
                                     initWithDoses:[MHVRandom randomDoubleInRangeMin:0 max:5]
                                     forDrug:[MHVCodableValue fromText:drug]
                                     onDate:date];
    
    return [[MHVItem alloc] initWithTypedData:usage];    
}

@end

@implementation MHVDietaryIntake (HVTestExtensions)

+(MHVItem *)createRandom
{
    MHVCodableValue* meal = [MHVCodableValue fromText:pickRandomString(2, @"Lunch", @"Dinner")];
    MHVCodableValue* food = [MHVCodableValue fromText:[meal.text stringByAppendingString:@"_Meal"]];
    return [MHVDietaryIntake createRandomValuesForFood:food meal:meal onDate:[MHVDateTime now]];
}

+(MHVItem *)createRandomValuesForFood:(MHVCodableValue *)food meal:(MHVCodableValue *)meal onDate:(MHVDateTime *)date
{
    MHVItem* item = [MHVDietaryIntake newItem];
    MHVDietaryIntake* diet = (MHVDietaryIntake *) item.data.typed;
    
    diet.foodItem = food;
    diet.meal = meal;
    diet.servingsConsumed = [[MHVNonNegativeDouble alloc] initWith:1];
    diet.when = date;
    
    diet.calories = [MHVFoodEnergyValue fromCalories:[MHVRandom randomIntInRangeMin:100 max:500]];
    diet.carbs = [MHVWeightMeasurement fromGrams:[MHVRandom randomIntInRangeMin:200 max:300]];
    
    diet.totalFat = [MHVWeightMeasurement createRandomGramsMin:20 max:50];
    diet.transFat = [MHVWeightMeasurement createRandomGramsMin:0 max:10];
    diet.saturatedFat = [MHVWeightMeasurement createRandomGramsMin:0 max:10];
    diet.monounsaturatedFat = [MHVWeightMeasurement createRandomGramsMin:0 max:5];
    diet.polyunsaturatedFat = [MHVWeightMeasurement createRandomGramsMin:0 max:3];
    
    diet.protein = [MHVWeightMeasurement createRandomGramsMin:0 max:25];
    diet.dietaryFiber = [MHVWeightMeasurement createRandomGramsMin:0 max:20];
    diet.sugar = [MHVWeightMeasurement createRandomGramsMin:0 max:50];
    diet.sodium = [MHVWeightMeasurement fromMillgrams:[MHVRandom randomIntInRangeMin:1 max:50]];
    diet.cholesterol = [MHVWeightMeasurement fromMillgrams:[MHVRandom randomIntInRangeMin:1 max:50]];
        
    return item;
    
LError:
    return nil;
}

@end

@implementation MHVTestSynchronizedStore : MHVSynchronizedStore

@synthesize failureProbability;

-(MHVItem *)getLocalItemWithKey:(MHVItemKey *)key
{
    if ([MHVRandom randomDouble] < self.failureProbability)
    {
        return nil;
    }
    
    return [super getLocalItemWithKey:key];
}

@end
