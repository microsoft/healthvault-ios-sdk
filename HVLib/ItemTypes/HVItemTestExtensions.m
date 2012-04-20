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
    return [[[HVDateTime alloc] initWithDate:createRandomDate()] autorelease];
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
    
    return org;
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

@implementation HVDietaryIntake (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem* item = [[HVDietaryIntake newItem] autorelease];
    HVDietaryIntake* diet = item.dietaryIntake;
    
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
    
    [exercise addOrUpdateDetailWithName:detailCode andValue:measurement];
    [exercise addOrUpdateDetailWithName:detailCode andValue:measurement];  
    
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
    
    NSString* medicationName = pickRandomString(8, @"Lipitor", @"Ibuprofen", @"Celebrex", @"Prozac", @"Claritin", @"Viagra", @"Omega 3 Supplement", @"Multi-vitamins");
    
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