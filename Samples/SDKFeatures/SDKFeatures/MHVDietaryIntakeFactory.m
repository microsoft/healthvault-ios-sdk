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

static MHVVocabIdentifier* s_vocabForMeals;

@implementation MHVDietaryIntake (HVFactoryMethods)

//
// Creates all 3 meals
//
+(MHVItemCollection *)createRandomForDay:(NSDate *)date
{
    MHVItemCollection* items = [[MHVItemCollection alloc] init];
    //
    // Breakfast
    //
    MHVDateTime* breakfastTime = [MHVDateTime fromDate:date];
    breakfastTime.time.hour = 7;
    breakfastTime.time.minute = 30;

    [items addObject:[MHVDietaryIntake makeBreakfastFor:breakfastTime]];
    //
    // Lunch
    //
    MHVDateTime* lunchTime = [MHVDateTime fromDate:date];
    lunchTime.time.hour = 12;
 
    [items addObject:[MHVDietaryIntake makeLunchEntreeFor:lunchTime]];
    [items addObject:[MHVDietaryIntake makeLunchVeggiesFor:lunchTime]];
    //
    // Dinner
    //
    MHVDateTime* dinnerTime = [MHVDateTime fromDate:date];
    dinnerTime.time.hour = 18;
    dinnerTime.time.minute = 30;
    [items addObject:[MHVDietaryIntake makeDinnerEntreeFor:dinnerTime]];
    [items addObject:[MHVDietaryIntake makeDinnerVeggiesFor:dinnerTime]];
    [items addObject:[MHVDietaryIntake makeDinnerDessertFor:dinnerTime]];

    return items;

LError:
    return nil;
}

+(MHVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVDietaryIntake createRandomForDay:date]; // No metric specific units
}

+(MHVItem *)makeBreakfastFor:(MHVDateTime *)breakfastTime
{    
    MHVItem* breakfast = [MHVDietaryIntake
                         createRandomValuesForFood:[MHVCodableValue fromText:@"BreakfastFood"]
                         meal:[MHVDietaryIntake mealCodeForBreakfast]
                         onDate:breakfastTime];
    
    return breakfast;
}

+(MHVItem *)makeLunchEntreeFor:(MHVDateTime *)lunchTime
{
    MHVItem* lunch = [MHVDietaryIntake
                     createRandomValuesForFood:[MHVCodableValue fromText:@"Lunch entree"]
                     meal:[MHVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(MHVItem *)makeLunchVeggiesFor:(MHVDateTime *)lunchTime
{
    MHVItem* lunch = [MHVDietaryIntake
                     createRandomValuesForFood:[MHVCodableValue fromText:@"Lunch Veggies"]
                     meal:[MHVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(MHVItem *)makeDinnerEntreeFor:(MHVDateTime *)dinnerTime
{
    MHVItem* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner entree"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;
}

+(MHVItem *)makeDinnerVeggiesFor:(MHVDateTime *)dinnerTime
{
    MHVItem* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner Veggies"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(MHVItem *)makeDinnerDessertFor:(MHVDateTime *)dinnerTime
{
    MHVItem* dinner = [MHVDietaryIntake
                      createRandomValuesForFood:[MHVCodableValue fromText:@"Dinner Dessert"]
                      meal:[MHVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(MHVVocabIdentifier *)getVocabForMeals
{
    if (s_vocabForMeals == nil)
    {
        s_vocabForMeals = [MHVDietaryIntake vocabForMeals];
    }
    
    return s_vocabForMeals;
}

@end

@implementation MHVDietaryIntake (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ [%.0f calories] %@", self.foodItem.description, self.calories.caloriesValue, self.meal ? self.meal.description : c_emptyString];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
