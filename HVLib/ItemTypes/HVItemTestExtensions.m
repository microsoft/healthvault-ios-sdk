//
//  HVItemTestExtensions.m
//  HVTestLib
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

#import "HVCommon.h"
#import "HVRandom.h"
#import "HVItemTestExtensions.h"

NSDate* createRandomDate(void)
{
    return [[HVRandom newRandomDayOffsetFromTodayInRangeMin:0 max:-365] autorelease];
}

HVDateTime* createRandomHVDateTime(void)
{
    return [HVDateTime fromDate:createRandomDate()];
}

HVDate* createRandomHVDate(void)
{
    return [[[HVDate alloc] initWithDate:createRandomDate()] autorelease]; 
}

HVApproxDateTime* createRandomApproxHVDate(void)
{
    return [[[HVApproxDateTime alloc] initWithDateTime:createRandomHVDateTime()] autorelease];
}

NSString* pickRandomString(int count, ...)
{
    va_list args;
    va_start(args, count);
    NSString* retVal = nil;
    
    int randomIndex = [HVRandom randomIntInRangeMin:0 max:count - 1];
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

@implementation HVContact (HVTestExtensions)

+(HVContact *)createRandom
{
    HVContact* contact = [[[HVContact alloc] init] autorelease];
    
    HVAddress* address = [[[HVAddress alloc] init] autorelease];
    [address.street addObject:@"1234 Princess Street"];
    address.city = @"Edinburgh";
    address.postalCode = @"ABCDEF";
    address.country = @"Scotland";
    
    HVEmail* email = [[[HVEmail alloc] initWithEmailAddress:@"foo@bar.xyz"] autorelease];
    HVPhone* phone = [[[HVPhone alloc] initWithNumber:@"555-555-5555"] autorelease];
    
    [contact.address addObject:address];
    [contact.email addObject:email];
    [contact.phone addObject:phone];
    
    return contact;
}

@end

@implementation HVPerson (HVTestExtensions)

+(HVPerson *) createRandom
{
    HVPerson* person = [[[HVPerson alloc] init] autorelease];
    
    person.name = [[[HVName alloc] initWithFirst:@"Toby" middle:@"R." andLastName:@"McDuff"] autorelease];
    person.organization = @"Justice League of Doctors";
    person.training = @"MD, Phd., AB, FRCS, PQRS, XYZ";
    
    person.contact = [HVContact createRandom];
    
    return person;
}

@end

@implementation HVOrganization (HVTestExtensions)

+(HVOrganization *)createRandom
{
    HVOrganization* org = [[[HVOrganization alloc] init] autorelease];
    org.name = @"Toto Memorial Hospital";
    org.contact = [HVContact createRandom];
    org.website = @"http://www.bing.com";
    
    return org;
}

@end

@implementation HVWeightMeasurement (HVTestExtensions)

+(HVWeightMeasurement *)createRandomGramsMin:(NSUInteger)min max:(NSUInteger)max
{
    int value = [HVRandom randomIntInRangeMin:min max:max];
    if (value <= 0)
    {
        return nil;
    }
    
    return [HVWeightMeasurement fromGrams:value];
}

@end

@implementation HVItem (HVTestExtensions)

+(HVItem *)createRandomOfClass:(NSString *)className
{
    Class cls = NSClassFromString(className);
    if (cls == nil)
    {
        return nil;
    }
    
    @try {
        return (HVItem *) [cls createRandom];
    }
    @catch (NSException *exception) 
    {
    }
    
    return nil;
}

@end

@implementation HVWeight (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem *item = [[HVWeight newItem] autorelease];
    
    item.weight.inPounds = [HVRandom randomDoubleInRangeMin:120 max:145];
    item.weight.when = createRandomHVDateTime();
    
    return item;    
}

@end

@implementation HVBloodPressure (HVTestExtensions)
    
+(HVItem *)createRandom
{
    HVItem *item = [[HVBloodPressure newItem] autorelease];
    HVBloodPressure *bp = item.bloodPressure;

    bp.when = createRandomHVDateTime();

    int s = [HVRandom randomIntInRangeMin:120 max:150];
    int d = s - [HVRandom randomIntInRangeMin:25 max:40];
    
    bp.systolicValue = s;
    bp.diastolicValue = d;
        
    return item;
}

@end

@implementation HVBloodGlucose (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVBloodGlucose newItem] autorelease];
    
    HVBloodGlucose* glucose = item.bloodGlucose;
    glucose.when = createRandomHVDateTime();
    
    glucose.inMgPerDL = [HVRandom randomDoubleInRangeMin:70 max:120];
    glucose.measurementType = [HVBloodGlucose createWholeBloodMeasurementType];
    
    glucose.isOutsideOperatingTemp = FALSE;
    
    return item;
}

@end

@implementation HVCholesterol (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVCholesterol newItem] autorelease];
    HVCholesterol* cholesterol = item.cholesterol;
    
    cholesterol.when = createRandomHVDate();
    cholesterol.ldlValue = [HVRandom randomIntInRangeMin:80 max:130];
    cholesterol.hdlValue = [HVRandom randomIntInRangeMin:30 max:60];
    cholesterol.totalValue = cholesterol.ldlValue + cholesterol.hdlValue + [HVRandom randomIntInRangeMin:20 max:50];
    cholesterol.triglyceridesValue = [HVRandom randomIntInRangeMin:150 max:250];
    
    return item;
}

@end

@implementation HVHeight (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVHeight newItem] autorelease];
    HVHeight* height = item.height;
    
    height.when = createRandomHVDateTime();
    height.inInches = [HVRandom randomIntInRangeMin:12 max:84];
    
    return item;
}

@end

@implementation HVDailyDietaryIntake (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVDailyDietaryIntake newItem] autorelease];
    HVDailyDietaryIntake* diet = item.dailyDietaryIntake;
    
    diet.when = createRandomHVDate();
    diet.caloriesValue = [HVRandom randomIntInRangeMin:1800 max:3000];
    diet.totalFatGrams = [HVRandom randomDoubleInRangeMin:0 max:100];
    diet.saturatedFatGrams = [HVRandom randomDoubleInRangeMin:0 max:diet.totalFatGrams];
    diet.proteinGrams = [HVRandom randomDoubleInRangeMin:1 max:100];
    diet.sugarGrams = [HVRandom randomDoubleInRangeMin:10 max:400];
    diet.dietaryFiberGrams = [HVRandom randomDoubleInRangeMin:1 max:100];
    diet.totalCarbGrams = diet.dietaryFiberGrams + diet.sugarGrams + [HVRandom randomDoubleInRangeMin:10 max:400];
    diet.cholesterolMilligrams = [HVRandom randomDoubleInRangeMin:0 max:100];
    
    return item;
}

@end

@implementation HVExercise (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVExercise newItem] autorelease];
    HVExercise* exercise = item.exercise;
    
    exercise.when = createRandomApproxHVDate();
    
    NSString* activity = pickRandomString(3, @"Aerobics", @"Walking", @"Running");
    [exercise setStandardActivity:activity];
    
    exercise.durationMinutesValue = [HVRandom randomDoubleInRangeMin:15 max:45];
    
    NSString* detailCode;
    HVMeasurement* measurement;
    if (activity == @"Walking") 
    {
        detailCode = @"Steps_count"; // see exercise-detail-names vocabulary
        measurement = [HVMeasurement fromValue:exercise.durationMinutesValue * 100 andUnitsString:@"steps"];
    }
    else 
    {
        detailCode = @"CaloriesBurned_calories";
        measurement = [HVMeasurement fromValue:exercise.durationMinutesValue * 5 andUnitsString:@"calories"];
    }
    
    [exercise addOrUpdateDetailWithNameCode:detailCode andValue:measurement];
    [exercise addOrUpdateDetailWithNameCode:detailCode andValue:measurement];  
    
    return item;
}

@end

@implementation HVAllergy (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVAllergy newItem] autorelease];
    HVAllergy* allergy = item.allergy;
    
    NSString* allergen = pickRandomString(3, @"Pollen", @"Peanuts", @"Penicillin");
    NSString* onset = pickRandomString(3, @"High School", @"As a child", @"Can't remember");
    
    allergy.name = [HVCodableValue fromText:[NSString stringWithFormat:@"Allergy to %@", allergen]];
    allergy.firstObserved = [HVApproxDateTime fromDescription:onset];
    if (allergen == @"Pollen")
    {
        allergy.allergenType = [HVCodableValue fromText:@"environmental"];
        allergy.reaction = [HVCodableValue fromText:@"sneezing"];
    }
    else if (allergen == @"Peanuts")
    {
        allergy.allergenType = [HVCodableValue fromText:@"food"];
        allergy.reaction = [HVCodableValue fromText:@"anaphylactic shock"];
    }
    else 
    {
        allergy.allergenType = [HVCodableValue fromText:@"medication"];
        allergy.reaction = [HVCodableValue fromText:@"anaphylactic shock"];
    }
    
    return item;
}

@end

@implementation HVCondition (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVCondition newItem] autorelease];
    HVCondition* condition = item.condition;
    
    NSString* conditionName = pickRandomString(5, @"Migraine", @"Pancreatitis", @"Mild Depression", @"Ulcer", @"Endometriosis");
    condition.name = [HVCodableValue fromText:conditionName];
    condition.status = [HVCodableValue fromText:pickRandomString(2, @"chronic", @"acute")];
    
    if ([HVRandom randomDouble] > 0.5)
    {
        condition.onsetDate = [HVApproxDateTime fromDescription:@"As a teenager"];
    }
    else 
    {
        condition.onsetDate = createRandomApproxHVDate();
    }
 
    return item;
}

@end

@implementation HVMedication (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVMedication newItem] autorelease];
    HVMedication* medication = item.medication;
    
    NSString* medicationName = pickRandomDrug();
    
    medication.name = [HVCodableValue fromText:medicationName];
    medication.dose = [HVApproxMeasurement fromValue:[HVRandom randomIntInRangeMin:1 max:4]
                                           unitsText:@"Tablets" unitsCode:@"Tablets" unitsVocab:@"medication-dose-units"];
    medication.strength = [HVApproxMeasurement fromValue:[HVRandom randomIntInRangeMin:100 max:1000] 
                                               unitsText:@"Milligrams" unitsCode:@"mg" unitsVocab:@"medication-strength-unit"];
    medication.frequency = [HVApproxMeasurement fromDisplayText:pickRandomString(3, @"Once a day", @"Twice a day", @"As needed")];
    
    medication.startDate = createRandomApproxHVDate();
    
    return item;
}

@end

@implementation HVImmunization (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVImmunization newItem] autorelease];
    HVImmunization* immunization = item.immunization;
    
    if ([HVRandom randomDouble] > 0.5)
    {
        immunization.name = [HVCodableValue fromText:@"hepatitis A and hepatitis B vaccine" code:@"104" andVocab:@"vaccines-cvx"];
    }
    else 
    {
        immunization.name = [HVCodableValue fromText:@"influenza virus vaccine, whole virus" code:@"16" andVocab:@"vaccines-cvx"];
    }
    immunization.name.codes.firstCode.vocabularyFamily = @"HL7";
    immunization.name.codes.firstCode.vocabularyVersion = @"2.3 09_2008";
    
    if ([HVRandom randomDouble] > 0.5)
    {
        immunization.administeredDate = [HVApproxDateTime fromDescription:@"As an adult"];
    }
    else
    {
        immunization.administeredDate = createRandomApproxHVDate();
    }
    if ([HVRandom randomDouble] > 0.5)
    {
        immunization.manufacturer = [HVCodableValue fromText:@"Merck & Co., Inc." code:@"MSD" andVocab:@"vaccine-manufacturers-mvx"];       
    }
    else 
    {
        immunization.manufacturer = [HVCodableValue fromText:@"GlaxoSmithKline" code:@"SKB" andVocab:@"vaccine-manufacturers-mvx"];       
    }
    
    immunization.lot = [NSString stringWithFormat:@"%d", [HVRandom randomIntInRangeMin:5000 max:20000]];
    immunization.route = [HVCodableValue fromText:@"Injected"];
            
    immunization.anatomicSurface = [HVCodableValue fromText:@"Right arm"];
    
    return item;
}

@end

@implementation HVProcedure (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVProcedure newItem] autorelease];
    HVProcedure* procedure = item.procedure;
    
    procedure.name = [HVCodableValue fromText:pickRandomString(3, @"eye surgery", @"root canal", @"colonoscopy")];
    procedure.when = createRandomApproxHVDate();
    procedure.primaryProvider = [HVPerson createRandom];
    
    return item;
}

@end

@implementation HVVitalSigns (HVTestExtensions)

+(HVItem *) createRandom
{
    HVItem* item = [[HVVitalSigns newItem] autorelease];
    HVVitalSigns* vitals = item.vitalSigns;
    
    double temperature = [HVRandom randomDoubleInRangeMin:97 max:103];
    long temp = (long) (temperature * 10);
    temperature = ((double) temp) * 0.1;
    
    HVVitalSignResult* result = [[[HVVitalSignResult alloc] initWithTemperature:temperature inCelsius:FALSE] autorelease];
    
    vitals.when = createRandomHVDateTime();
    [vitals.results addObject:result];
    
    return item;
}

@end

@implementation HVEncounter (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVEncounter newItem] autorelease];
    HVEncounter* encounter = item.encounter;
    
    encounter.when = createRandomHVDateTime();
    encounter.encounterType = [HVCodableValue fromText:pickRandomString(3, @"Checkup Examination", @"Dental Procedures", @"Acute care")];
    encounter.duration = [[[HVDuration alloc] initWithDate:[encounter.when toDate] andDurationInSeconds:3600] autorelease];
    encounter.facility = [HVOrganization createRandom];
    
    return item;
}

@end

@implementation HVFamilyHistory (HVTestExtensions)

+(HVItem *)createRandom
{
    HVRelative* relative = [[[HVRelative alloc] initWithRelationship:pickRandomString(4, @"Mother", @"Father", @"Grandmother", @"Grandfather")] autorelease];
    HVConditionEntry* condition = [[[HVConditionEntry alloc] initWithName:pickRandomString(4, @"Cancer", @"Heart Disease", @"Diabetes", @"Alzheimers")] autorelease];
    
    HVFamilyHistory* history = [[[HVFamilyHistory alloc] initWithRelative:relative andCondition:condition] autorelease];
    
    return [[[HVItem alloc] initWithTypedData:history] autorelease];
}

@end

@implementation HVAssessment (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVAssessment newItem] autorelease];
    HVAssessment* assessment = item.assessment;
    
    assessment.when = createRandomHVDateTime();
    assessment.category = [HVCodableValue fromText:@"Self Assessment"];
    assessment.name = pickRandomString(3, @"Stress Assessment", @"Aerobic Fitness", @"Mental Fitness");
    [assessment.results addObject:[HVAssessmentField from:@"Status" andValue:pickRandomString(2, @"Good", @"Bad")]];
    [assessment.results addObject:[HVAssessmentField from:@"Needs Help" andValue:pickRandomString(2, @"Yes", @"No")]];

    return item;
}

@end

@implementation HVQuestionAnswer (HVTestExtensions)

+(HVItem *)createRandom
{
    int number = [HVRandom randomIntInRangeMin:1 max:100];
    NSString* question = [NSString stringWithFormat:@"Question %d ?", number];
    NSString* answer = [NSString stringWithFormat:@"Answer to %d", number];
    
    HVQuestionAnswer* qa = [[[HVQuestionAnswer alloc] initWithQuestion:question answer:answer andDate:createRandomDate()] autorelease];
    
    return [[[HVItem alloc] initWithTypedData:qa] autorelease];
}

@end

@implementation HVEmergencyOrProviderContact (HVTestExtensions)

+(HVItem *)createRandom
{
    HVPerson* person;
    
    if ([HVRandom randomDouble] > 0.5)
    {
        person = [[[HVPerson alloc] initWithFirstName:@"Bingo" lastName:@"Little" phone:@"555-555-0000" andEmail:@"bingo@little.pqr"] autorelease];
    }
    else 
    {
        person = [[[HVPerson alloc] initWithName:@"Toby R. McDuff" phone:@"555-555-1111" andEmail:@"toby@mcduff.pqr"] autorelease];
    }
    person.type = [HVCodableValue fromText:@"Provider"];
    HVEmergencyOrProviderContact* contact = [[[HVEmergencyOrProviderContact alloc] initWithPerson:person] autorelease];
    return [[[HVItem alloc] initWithTypedData:contact] autorelease];
}

@end

@implementation HVPersonalContactInfo (HVTestExtensions)

+(HVItem *) createRandom
{
    HVItem* item = [[HVPersonalContactInfo newItem] autorelease];
    HVPersonalContactInfo* personalContact = item.personalContact;
    
    personalContact.contact = [HVContact createRandom];
    
    return item;
}

@end

@implementation HVSleepJournalAM (HVTestExtensions)

+(HVItem *) createRandom
{
    HVItem* item = [[HVSleepJournalAM newItem] autorelease];
    HVSleepJournalAM* journal = item.sleepJournalAM;
    
    journal.when = createRandomHVDateTime();
    
    HVTime* bedtime = [HVTime fromHour:[HVRandom randomIntInRangeMin:11 max:12] andMinute:[HVRandom randomIntInRangeMin:1 max:59]];
    
    journal.bedTime = bedtime;
    journal.settlingMinutesValue = [HVRandom randomIntInRangeMin:5 max:30];
    journal.sleepMinutesValue = [HVRandom randomIntInRangeMin:180 max:360];
    
    int awakeMinutes =  [HVRandom randomIntInRangeMin:0 max:55];
    if (awakeMinutes > 0)
    {
        HVOccurence* awakening = [HVOccurence forDuration:awakeMinutes atHour:(bedtime.hour) + 2 andMinute:bedtime.minute];
        [journal.awakenings addObject:awakening];
    }
    int bedMinutes = journal.settlingMinutesValue + journal.sleepMinutesValue + [HVRandom randomIntInRangeMin:5 max:55];
    HVTime* wakeTime = [HVTime fromHour:journal.bedTime.hour + (bedMinutes / 60) andMinute:bedMinutes % 60];
    
    journal.wakeTime = wakeTime;
    
    journal.wakeState = (enum HVWakeState) [HVRandom randomIntInRangeMin:1 max:3];
    
    return item;
}

@end

@implementation HVSleepJournalPM (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVSleepJournalPM newItem] autorelease];
    HVSleepJournalPM* journal = item.sleepJournalPM;
    
    journal.when = createRandomHVDateTime();
    journal.sleepiness = (enum HVSleepiness) [HVRandom randomIntInRangeMin:1 max:4];
    
    for (int i = 0, count = [HVRandom randomIntInRangeMin:3 max:5]; i < count; ++i)
    {
        HVTime* time = [HVTime fromHour:[HVRandom randomIntInRangeMin:7 max:20] andMinute:[HVRandom randomIntInRangeMin:1 max:59]];
        [journal.caffeineIntakeTimes addObject:time];        
    }
                                                                                    
    return item;
}

@end

@implementation HVEmotionalState (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVEmotionalState newItem] autorelease];
    HVEmotionalState* es = item.emotionalState;
    
    es.when = createRandomHVDateTime();
    es.stress = (enum HVRelativeRating) [HVRandom randomIntInRangeMin:1 max:5];
    es.mood = (enum HVMood) [HVRandom randomIntInRangeMin:1 max:5];
    es.wellbeing = (enum HVWellBeing) [HVRandom randomIntInRangeMin:1 max:5];

    return item;
}

@end

@implementation HVDailyMedicationUsage (HVTestExtensions)

+(HVItem *)createRandom
{
    HVDailyMedicationUsage* usage = [[HVDailyMedicationUsage alloc] 
                                    initWithDoses:[HVRandom randomDoubleInRangeMin:0 max:5]
                                     forDrug:[HVCodableValue fromText:pickRandomDrug()] 
                                     onDay:createRandomDate()];    
    return [[[HVItem alloc] initWithTypedData:[usage autorelease]] autorelease];
}

@end

@implementation HVDietaryIntake (HVTestExtensions)

+(HVItem *)createRandom
{
    HVCodableValue* meal = [HVCodableValue fromText:pickRandomString(2, @"Lunch", @"Dinner")];
    HVCodableValue* food = [HVCodableValue fromText:[meal.text stringByAppendingString:@"_Meal"]];
    return [HVDietaryIntake createRandomValuesForFood:food meal:meal onDate:[HVDateTime now]];
}

+(HVItem *)createRandomValuesForFood:(HVCodableValue *)food meal:(HVCodableValue *)meal onDate:(HVDateTime *)date
{
    HVItem* item = [[HVDietaryIntake newItem] autorelease];
    HVDietaryIntake* diet = (HVDietaryIntake *) item.data.typed;
    
    diet.foodItem = food;
    diet.meal = meal;
    diet.servingsConsumed = [[[HVNonNegativeDouble alloc] initWith:1] autorelease];
    diet.when = date;
    
    diet.calories = [HVFoodEnergyValue fromCalories:[HVRandom randomIntInRangeMin:100 max:500]];
    diet.carbs = [HVWeightMeasurement fromGrams:[HVRandom randomIntInRangeMin:200 max:300]];
    
    diet.totalFat = [HVWeightMeasurement createRandomGramsMin:20 max:50];
    diet.transFat = [HVWeightMeasurement createRandomGramsMin:0 max:10];
    diet.saturatedFat = [HVWeightMeasurement createRandomGramsMin:0 max:10];
    diet.monounsaturatedFat = [HVWeightMeasurement createRandomGramsMin:0 max:5];
    diet.polyunsaturatedFat = [HVWeightMeasurement createRandomGramsMin:0 max:3];
    
    diet.protein = [HVWeightMeasurement createRandomGramsMin:0 max:25];
    diet.dietaryFiber = [HVWeightMeasurement createRandomGramsMin:0 max:20];
    diet.sugar = [HVWeightMeasurement createRandomGramsMin:0 max:50];
    diet.sodium = [HVWeightMeasurement fromMillgrams:[HVRandom randomIntInRangeMin:1 max:50]];
    diet.cholesterol = [HVWeightMeasurement fromMillgrams:[HVRandom randomIntInRangeMin:1 max:50]];
        
    return item;
    
LError:
    return nil;
}

@end

@implementation HVTestSynchronizedStore : HVSynchronizedStore

@synthesize failureProbability;

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
{
    if ([HVRandom randomDouble] < self.failureProbability)
    {
        return nil;
    }
    
    return [super getLocalItemWithKey:key];
}

@end