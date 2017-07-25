//
//  MHVDietaryIntakeFactory.m
//  SDKFeatures
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
#import "MHVUIAlert.h"
#import "MHVDietaryIntakeFactory.h"

static MHVVocabularyIdentifier* s_vocabForMeals;

@implementation MHVDietaryIntake (MHVFactoryMethods)

//
// Creates all 3 meals
//
+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    //
    // Breakfast
    //
    MHVDateTime* breakfastTime = [MHVDateTime fromDate:date];
    breakfastTime.time.hour = 7;
    breakfastTime.time.minute = 30;

    [things addObject:[MHVDietaryIntake makeBreakfastFor:breakfastTime]];
    //
    // Lunch
    //
    MHVDateTime* lunchTime = [MHVDateTime fromDate:date];
    lunchTime.time.hour = 12;
 
    [things addObject:[MHVDietaryIntake makeLunchEntreeFor:lunchTime]];
    [things addObject:[MHVDietaryIntake makeLunchVeggiesFor:lunchTime]];
    //
    // Dinner
    //
    MHVDateTime* dinnerTime = [MHVDateTime fromDate:date];
    dinnerTime.time.hour = 18;
    dinnerTime.time.minute = 30;
    [things addObject:[MHVDietaryIntake makeDinnerEntreeFor:dinnerTime]];
    [things addObject:[MHVDietaryIntake makeDinnerVeggiesFor:dinnerTime]];
    [things addObject:[MHVDietaryIntake makeDinnerDessertFor:dinnerTime]];

    return things;
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVDietaryIntake createRandomForDay:date]; // No metric specific units
}

+(MHVThing *)makeBreakfastFor:(MHVDateTime *)breakfastTime
{    
    MHVThing* breakfast = [MHVDietaryIntake
                         createRandomValuesForFood:[MHVCodableValue fromText:@"BreakfastFood"]
                         meal:[MHVDietaryIntake mealCodeForBreakfast]
                         onDate:breakfastTime];
    
    return breakfast;
}

+(MHVThing *)makeLunchEntreeFor:(MHVDateTime *)lunchTime
{
    MHVThing* lunch = [MHVDietaryIntake
                     createRandomValuesForFood:[MHVCodableValue fromText:@"Lunch entree"]
                     meal:[MHVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(MHVThing *)makeLunchVeggiesFor:(MHVDateTime *)lunchTime
{
    MHVThing* lunch = [MHVDietaryIntake
                     createRandomValuesForFood:[MHVCodableValue fromText:@"Lunch Veggies"]
                     meal:[MHVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(MHVThing *)makeDinnerEntreeFor:(MHVDateTime *)dinnerTime
{
    MHVThing* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner entree"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;
}

+(MHVThing *)makeDinnerVeggiesFor:(MHVDateTime *)dinnerTime
{
    MHVThing* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner Veggies"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(MHVThing *)makeDinnerDessertFor:(MHVDateTime *)dinnerTime
{
    MHVThing* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner Dessert"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(MHVVocabularyIdentifier *)getVocabForMeals
{
    if (s_vocabForMeals == nil)
    {
        s_vocabForMeals = [MHVDietaryIntake vocabForMeals];
    }
    
    return s_vocabForMeals;
}

@end

@implementation MHVDietaryIntake (MHVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ [%.0f calories] %@", self.foodThing.description, self.calories.caloriesValue, self.meal ? self.meal.description : @""];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
