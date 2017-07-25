//
// MHVThingTestExtensions.m
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

#import "MHVRandom.h"
#import "MHVThingTestExtensions.h"

double roundToPrecision(double value, NSInteger precision)
{
    double places;
    
    // Optimize the common case
    switch (precision)
    {
        case 0:
            places = 1;
            break;
            
        case 1:
            places = 10;
            break;
            
        case 2:
            places = 100;
            break;
            
        case 3:
            places = 1000;
            break;
            
        default:
            places = pow(10, precision);
            break;
    }
    return round(value * places) / places;
}

NSDate *createRandomDate(void)
{
    return [MHVRandom newRandomDayOffsetFromTodayInRangeMin:0 max:-365];
}

MHVDateTime *createRandomMHVDateTime(void)
{
    return [MHVDateTime fromDate:createRandomDate()];
}

MHVDate *createRandomMHVDate(void)
{
    return [[MHVDate alloc] initWithDate:createRandomDate()];
}

MHVApproxDateTime *createRandomApproxMHVDate(void)
{
    return [[MHVApproxDateTime alloc] initWithDateTime:createRandomMHVDateTime()];
}

NSString *pickRandomString(int count, ...)
{
    va_list args;
    
    va_start(args, count);
    NSString *retVal = nil;
    
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

NSString *pickRandomDrug(void)
{
    return pickRandomString(8, @"Lipitor", @"Ibuprofen", @"Celebrex", @"Prozac", @"Claritin", @"Viagra", @"Omega 3 Supplement", @"Multi-vitamins");
}

@implementation MHVContact (MHVTestExtensions)

+ (MHVContact *)createRandom
{
    MHVContact *contact = [[MHVContact alloc] init];
    
    MHVAddress *address = [[MHVAddress alloc] init];
    
    address.street = @[@"1234 Princess Street"];
    address.city = @"Edinburgh";
    address.postalCode = @"ABCDEF";
    address.country = @"Scotland";
    
    MHVEmail *email = [[MHVEmail alloc] initWithEmailAddress:@"foo@bar.xyz"];
    MHVPhone *phone = [[MHVPhone alloc] initWithNumber:@"555-555-5555"];
    
    contact.address = @[address];
    contact.email = @[email];
    contact.phone = @[phone];
    
    return contact;
}

@end

@implementation MHVPerson (MHVTestExtensions)

+ (MHVPerson *)createRandom
{
    MHVPerson *person = [[MHVPerson alloc] init];
    
    person.name = [[MHVName alloc] initWithFirst:@"Toby" middle:@"R." andLastName:@"McDuff"];
    person.organization = @"Justice League of Doctors";
    person.training = @"MD, Phd., AB, FRCS, PQRS, XYZ";
    
    person.contact = [MHVContact createRandom];
    
    return person;
}

@end

@implementation MHVOrganization (MHVTestExtensions)

+ (MHVOrganization *)createRandom
{
    MHVOrganization *org = [[MHVOrganization alloc] init];
    
    org.name = @"Toto Memorial Hospital";
    org.contact = [MHVContact createRandom];
    org.website = @"http://www.bing.com";
    
    return org;
}

@end

@implementation MHVWeightMeasurement (MHVTestExtensions)

+ (MHVWeightMeasurement *)createRandomGramsMin:(NSUInteger)min max:(NSUInteger)max
{
    int value = [MHVRandom randomIntInRangeMin:(int)min max:(int)max];
    
    if (value <= 0)
    {
        return nil;
    }
    
    return [MHVWeightMeasurement fromGrams:value];
}

@end

@implementation MHVThing (MHVTestExtensions)

+ (MHVThing *)createRandomOfClass:(NSString *)className
{
    Class cls = NSClassFromString(className);
    
    if (cls == nil)
    {
        return nil;
    }
    
    @try
    {
        return (MHVThing *)[cls createRandom];
    }
    @catch (NSException *exception)
    {
    }
    
    return nil;
}

@end

@implementation MHVWeight (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVWeight createRandomForDate:createRandomMHVDateTime()];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime
{
    MHVThing *thing = [MHVWeight newThing];
    
    thing.weight.when = dateTime;
    
    double pounds = [MHVRandom randomDoubleInRangeMin:120 max:145];
    pounds = roundToPrecision(pounds, 1);
    thing.weight.inPounds = pounds;
    
    return thing;
}

+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    MHVThing *thing = [MHVWeight newThing];
    
    thing.weight.when = dateTime;
    
    double kg = [MHVRandom randomDoubleInRangeMin:50 max:75];
    kg = roundToPrecision(kg, 1);
    thing.weight.inKg = kg;
    
    return thing;
}

@end

@implementation MHVBloodPressure (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVBloodPressure createRandomForDate:createRandomMHVDateTime() withPulse:FALSE];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime withPulse:(BOOL)pulse
{
    MHVThing *thing = [MHVBloodPressure newThing];
    MHVBloodPressure *bp = thing.bloodPressure;
    
    bp.when = dateTime;
    
    int s = [MHVRandom randomIntInRangeMin:120 max:150];
    int d = s - [MHVRandom randomIntInRangeMin:25 max:40];
    
    bp.systolicValue = s;
    bp.diastolicValue = d;
    
    if (pulse)
    {
        bp.pulseValue = [MHVRandom randomIntInRangeMin:60 max:100];
    }
    
    return thing;
}

@end

@implementation MHVBloodGlucose (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVBloodGlucose createRandomForDate:createRandomMHVDateTime()];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime
{
    return [MHVBloodGlucose createRandomForDate:dateTime metric:FALSE];
}

+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    return [MHVBloodGlucose createRandomForDate:dateTime metric:TRUE];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric
{
    MHVThing *thing = [MHVBloodGlucose newThing];
    MHVBloodGlucose *glucose = thing.bloodGlucose;
    
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
    
    [thing updateEndDate:[dateTime toDate]];
    
    return thing;
}

@end

@implementation MHVCholesterol (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVCholesterol createRandomForDate:createRandomMHVDateTime()];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime
{
    return [MHVCholesterol createRandomForDate:dateTime metric:FALSE];
}

+ (MHVThing *)createRandomMetricForDate:(MHVDateTime *)dateTime
{
    return [MHVCholesterol createRandomForDate:dateTime metric:TRUE];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime metric:(BOOL)metric
{
    MHVThing *thing = [MHVCholesterol newThing];
    MHVCholesterol *cholesterol = thing.cholesterol;
    
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
    
    return thing;
}

@end

@implementation MHVHeartRate (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVHeartRate createRandomForDate:createRandomMHVDateTime()];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)dateTime;
{
    MHVThing *thing = [MHVHeartRate newThing];
    MHVHeartRate *heartRate = thing.heartRate;
    
    heartRate.when = dateTime;
    heartRate.bpmValue = [MHVRandom randomIntInRangeMin:60 max:140];
    
    return thing;
}
@end

@implementation MHVHeight (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVHeight newThing];
    MHVHeight *height = thing.height;
    
    height.when = createRandomMHVDateTime();
    height.inInches = [MHVRandom randomIntInRangeMin:12 max:84];
    
    return thing;
}

@end

@implementation MHVDailyDietaryIntake (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVDailyDietaryIntake newThing];
    MHVDailyDietaryIntake *diet = thing.dailyDietaryIntake;
    
    diet.when = createRandomMHVDate();
    diet.caloriesValue = [MHVRandom randomIntInRangeMin:1800 max:3000];
    diet.totalFatGrams = [MHVRandom randomDoubleInRangeMin:0 max:100];
    diet.saturatedFatGrams = [MHVRandom randomDoubleInRangeMin:0 max:diet.totalFatGrams];
    diet.proteinGrams = [MHVRandom randomDoubleInRangeMin:1 max:100];
    diet.sugarGrams = [MHVRandom randomDoubleInRangeMin:10 max:400];
    diet.dietaryFiberGrams = [MHVRandom randomDoubleInRangeMin:1 max:100];
    diet.totalCarbGrams = diet.dietaryFiberGrams + diet.sugarGrams + [MHVRandom randomDoubleInRangeMin:10 max:400];
    diet.cholesterolMilligrams = [MHVRandom randomDoubleInRangeMin:0 max:100];
    
    return thing;
}

@end

@implementation MHVExercise (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVExercise createRandomForDate:createRandomApproxMHVDate()];
}

+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date
{
    return [MHVExercise createRandomForDate:date metric:FALSE];
}

+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date metric:(BOOL)metric
{
    MHVThing *thing = [MHVExercise newThing];
    MHVExercise *exercise = thing.exercise;
    
    exercise.when = date;
    
    NSString *activity = pickRandomString(3, @"Aerobics", @"Walking", @"Running");
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
    
    MHVCodedValue *detailCode;
    MHVMeasurement *measurement;
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
        
        [exercise addOrUpdateDetailWithNameCode:detailCode.code andValue:measurement];
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
        
        [exercise addOrUpdateDetailWithNameCode:detailCode.code andValue:measurement];
    }
    
    return thing;
}

@end

@implementation MHVAllergy (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVAllergy newThing];
    MHVAllergy *allergy = thing.allergy;
    
    NSString *allergen = pickRandomString(3, @"Pollen", @"Peanuts", @"Penicillin");
    NSString *onset = pickRandomString(3, @"High School", @"As a child", @"Can't remember");
    
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
    
    return thing;
}

@end

@implementation MHVCondition (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVCondition newThing];
    MHVCondition *condition = thing.condition;
    
    NSString *conditionName = pickRandomString(5, @"Migraine", @"Pancreatitis", @"Mild Depression", @"Ulcer", @"Endometriosis");
    
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
    
    return thing;
}

@end

@implementation MHVMedication (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVMedication createRandomForDate:createRandomApproxMHVDate()];
}

+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date
{
    MHVThing *thing = [MHVMedication newThing];
    MHVMedication *medication = thing.medication;
    
    NSString *medicationName = pickRandomDrug();
    
    medication.name = [MHVCodableValue fromText:medicationName];
    medication.dose = [MHVApproxMeasurement fromValue:[MHVRandom randomIntInRangeMin:1 max:4]
                                            unitsText:@"Tablets" unitsCode:@"Tablets" unitsVocab:@"medication-dose-units"];
    medication.strength = [MHVApproxMeasurement fromValue:[MHVRandom randomIntInRangeMin:100 max:1000]
                                                unitsText:@"Milligrams" unitsCode:@"mg" unitsVocab:@"medication-strength-unit"];
    medication.frequency = [MHVApproxMeasurement fromDisplayText:pickRandomString(3, @"Once a day", @"Twice a day", @"As needed")];
    
    medication.startDate = date;
    
    return thing;
}

@end

@implementation MHVImmunization (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVApproxDateTime *date = nil;
    
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

+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date
{
    MHVThing *thing = [MHVImmunization newThing];
    MHVImmunization *immunization = thing.immunization;
    
    immunization.administeredDate = date;
    
    if ([MHVRandom randomDouble] > 0.5)
    {
        immunization.name = [MHVCodableValue fromText:@"hepatitis A and hepatitis B vaccine" code:@"104" andVocab:@"vaccines-cvx"];
    }
    else
    {
        immunization.name = [MHVCodableValue fromText:@"influenza virus vaccine, whole virus" code:@"16" andVocab:@"vaccines-cvx"];
    }
    
    immunization.name.codes.firstObject.vocabularyFamily = @"HL7";
    immunization.name.codes.firstObject.vocabularyVersion = @"2.3 09_2008";
    
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
    
    return thing;
}

@end

@implementation MHVProcedure (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVProcedure createRandomForDate:createRandomApproxMHVDate()];
}

+ (MHVThing *)createRandomForDate:(MHVApproxDateTime *)date
{
    MHVThing *thing = [MHVProcedure newThing];
    MHVProcedure *procedure = thing.procedure;
    
    procedure.name = [MHVCodableValue fromText:pickRandomString(3, @"eye surgery", @"root canal", @"colonoscopy")];
    procedure.when = date;
    procedure.primaryProvider = [MHVPerson createRandom];
    
    return thing;
}

@end

@implementation MHVVitalSigns (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVVitalSigns newThing];
    MHVVitalSigns *vitals = thing.vitalSigns;
    
    double temperature = [MHVRandom randomDoubleInRangeMin:97 max:103];
    long temp = (long)(temperature * 10);
    
    temperature = ((double)temp) * 0.1;
    
    MHVVitalSignResult *result = [[MHVVitalSignResult alloc] initWithTemperature:temperature inCelsius:FALSE];
    
    vitals.when = createRandomMHVDateTime();
    vitals.results = @[result];
    
    return thing;
}

@end

@implementation MHVEncounter (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVEncounter newThing];
    MHVEncounter *encounter = thing.encounter;
    
    encounter.when = createRandomMHVDateTime();
    encounter.encounterType = [MHVCodableValue fromText:pickRandomString(3, @"Checkup Examination", @"Dental Procedures", @"Acute care")];
    encounter.duration = [[MHVDuration alloc] initWithDate:[encounter.when toDate] andDurationInSeconds:3600];
    encounter.facility = [MHVOrganization createRandom];
    
    return thing;
}

@end

@implementation MHVFamilyHistory (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVRelative *relative = [[MHVRelative alloc] initWithRelationship:pickRandomString(4, @"Mother", @"Father", @"Grandmother", @"Grandfather")];
    MHVConditionEntry *condition = [[MHVConditionEntry alloc] initWithName:pickRandomString(4, @"Cancer", @"Heart Disease", @"Diabetes", @"Alzheimers")];
    
    MHVFamilyHistory *history = [[MHVFamilyHistory alloc] initWithRelative:relative andCondition:condition];
    
    return [[MHVThing alloc] initWithTypedData:history];
}

@end

@implementation MHVAssessment (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVAssessment newThing];
    MHVAssessment *assessment = thing.assessment;
    
    assessment.when = createRandomMHVDateTime();
    assessment.category = [MHVCodableValue fromText:@"Self Assessment"];
    assessment.name = pickRandomString(3, @"Stress Assessment", @"Aerobic Fitness", @"Mental Fitness");
    
    assessment.results = @[[MHVAssessmentField from:@"Status"
                                           andValue:pickRandomString(2, @"Good", @"Bad")]];
    assessment.results = @[[MHVAssessmentField from:@"Needs Help"
                                           andValue:pickRandomString(2, @"Yes", @"No")]];
    
    return thing;
}

@end

@implementation MHVQuestionAnswer (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    int number = [MHVRandom randomIntInRangeMin:1 max:100];
    NSString *question = [NSString stringWithFormat:@"Question %d ?", number];
    NSString *answer = [NSString stringWithFormat:@"Answer to %d", number];
    
    MHVQuestionAnswer *qa = [[MHVQuestionAnswer alloc] initWithQuestion:question answer:answer andDate:createRandomDate()];
    
    return [[MHVThing alloc] initWithTypedData:qa];
}

@end

@implementation MHVEmergencyOrProviderContact (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVPerson *person;
    
    if ([MHVRandom randomDouble] > 0.5)
    {
        person = [[MHVPerson alloc] initWithFirstName:@"Bingo" lastName:@"Little" phone:@"555-555-0000" andEmail:@"bingo@little.pqr"];
    }
    else
    {
        person = [[MHVPerson alloc] initWithName:@"Toby R. McDuff" phone:@"555-555-1111" andEmail:@"toby@mcduff.pqr"];
    }
    
    person.type = [MHVCodableValue fromText:@"Provider"];
    MHVEmergencyOrProviderContact *contact = [[MHVEmergencyOrProviderContact alloc] initWithPerson:person];
    return [[MHVThing alloc] initWithTypedData:contact];
}

@end

@implementation MHVPersonalContactInfo (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVPersonalContactInfo newThing];
    MHVPersonalContactInfo *personalContact = thing.personalContact;
    
    personalContact.contact = [MHVContact createRandom];
    
    return thing;
}

@end

@implementation MHVSleepJournalAM (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVSleepJournalAM createRandomForDate:createRandomMHVDateTime() withAwakenings:TRUE];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)date withAwakenings:(BOOL)doAwakenings
{
    MHVThing *thing = [MHVSleepJournalAM newThing];
    MHVSleepJournalAM *journal = thing.sleepJournalAM;
    
    date.time = nil; // Don't bother noting down the time. Date is enough
    journal.when = date;
    
    MHVTime *bedtime = [MHVTime fromHour:[MHVRandom randomIntInRangeMin:22 max:23] andMinute:[MHVRandom randomIntInRangeMin:1 max:59]];
    
    journal.bedTime = bedtime;
    journal.settlingMinutesValue = [MHVRandom randomIntInRangeMin:5 max:30];
    journal.sleepMinutesValue = [MHVRandom randomIntInRangeMin:180 max:360];
    
    int awakeMinutes =  [MHVRandom randomIntInRangeMin:0 max:55];
    if (awakeMinutes > 0 && doAwakenings)
    {
        MHVOccurence *awakening = [MHVOccurence forDuration:awakeMinutes atHour:((bedtime.hour) + 2) % 24 andMinute:bedtime.minute];
        
        journal.awakenings = @[awakening];
    }
    
    int bedMinutes = journal.settlingMinutesValue + journal.sleepMinutesValue + [MHVRandom randomIntInRangeMin:5 max:55];
    
    int wakeupHour = (journal.bedTime.hour + (bedMinutes / 60)) % 24;
    MHVTime *wakeTime = [MHVTime fromHour:wakeupHour andMinute:bedMinutes % 60];
    
    journal.wakeTime = wakeTime;
    
    journal.wakeState = (MHVWakeState)[MHVRandom randomIntInRangeMin:1 max:3];
    
    return thing;
}

@end

@implementation MHVSleepJournalPM (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVThing *thing = [MHVSleepJournalPM newThing];
    MHVSleepJournalPM *journal = thing.sleepJournalPM;
    
    journal.when = createRandomMHVDateTime();
    journal.sleepiness = (MHVSleepiness)[MHVRandom randomIntInRangeMin:1 max:4];
    
    NSMutableArray<MHVTime *> *times = [NSMutableArray new];
    for (int i = 0, count = [MHVRandom randomIntInRangeMin:3 max:5]; i < count; ++i)
    {
        MHVTime *time = [MHVTime fromHour:[MHVRandom randomIntInRangeMin:7 max:20] andMinute:[MHVRandom randomIntInRangeMin:1 max:59]];
        
        [times addObject:time];
    }
    journal.caffeineIntakeTimes = times;
    
    return thing;
}

@end

@implementation MHVEmotionalState (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    return [MHVEmotionalState createRandomForDate:createRandomMHVDateTime()];
}

+ (MHVThing *)createRandomForDate:(MHVDateTime *)date
{
    MHVThing *thing = [MHVEmotionalState newThing];
    MHVEmotionalState *es = thing.emotionalState;
    
    es.when = date;
    
    int randInt;
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.stress = (MHVRelativeRating)randInt;
    }
    
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.mood = (MHVMood)randInt;
    }
    
    randInt = [MHVRandom randomIntInRangeMin:0 max:5];
    if (randInt > 0)
    {
        es.wellbeing = (MHVWellBeing)randInt;
    }
    
    return thing;
}

@end

@implementation MHVDailyMedicationUsage (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    NSDate *date = createRandomDate();
    
    return [MHVDailyMedicationUsage createRandomForDate:[MHVDate fromDate:date]];
}

+ (MHVThing *)createRandomForDate:(MHVDate *)date
{
    NSString *drugName = pickRandomDrug();
    
    return [MHVDailyMedicationUsage createRandomForDate:date forDrug:drugName];
}

+ (MHVThing *)createRandomForDate:(MHVDate *)date forDrug:(NSString *)drug
{
    MHVDailyMedicationUsage *usage = [[MHVDailyMedicationUsage alloc]
                                      initWithDoses:[MHVRandom randomDoubleInRangeMin:0 max:5]
                                      forDrug:[MHVCodableValue fromText:drug]
                                      onDate:date];
    
    return [[MHVThing alloc] initWithTypedData:usage];
}

@end

@implementation MHVDietaryIntake (MHVTestExtensions)

+ (MHVThing *)createRandom
{
    MHVCodableValue *meal = [MHVCodableValue fromText:pickRandomString(2, @"Lunch", @"Dinner")];
    MHVCodableValue *food = [MHVCodableValue fromText:[meal.text stringByAppendingString:@"_Meal"]];
    
    return [MHVDietaryIntake createRandomValuesForFood:food meal:meal onDate:[MHVDateTime now]];
}

+ (MHVThing *)createRandomValuesForFood:(MHVCodableValue *)food meal:(MHVCodableValue *)meal onDate:(MHVDateTime *)date
{
    MHVThing *thing = [MHVDietaryIntake newThing];
    MHVDietaryIntake *diet = (MHVDietaryIntake *)thing.data.typed;
    
    diet.foodThing = food;
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
    
    return thing;
}

@end
