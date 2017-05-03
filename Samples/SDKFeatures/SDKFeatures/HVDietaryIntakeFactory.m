//
//  HVDietaryIntakeFactory.m
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
#import "HVUIAlert.h"
#import "HVDietaryIntakeFactory.h"

static HVVocabIdentifier* s_vocabForMeals;

@implementation HVDietaryIntake (HVFactoryMethods)

//
// Creates all 3 meals
//
+(HVItemCollection *)createRandomForDay:(NSDate *)date
{
    HVItemCollection* items = [[HVItemCollection alloc] init];
    //
    // Breakfast
    //
    HVDateTime* breakfastTime = [HVDateTime fromDate:date];
    breakfastTime.time.hour = 7;
    breakfastTime.time.minute = 30;

    [items addObject:[HVDietaryIntake makeBreakfastFor:breakfastTime]];
    //
    // Lunch
    //
    HVDateTime* lunchTime = [HVDateTime fromDate:date];
    lunchTime.time.hour = 12;
 
    [items addObject:[HVDietaryIntake makeLunchEntreeFor:lunchTime]];
    [items addObject:[HVDietaryIntake makeLunchVeggiesFor:lunchTime]];
    //
    // Dinner
    //
    HVDateTime* dinnerTime = [HVDateTime fromDate:date];
    dinnerTime.time.hour = 18;
    dinnerTime.time.minute = 30;
    [items addObject:[HVDietaryIntake makeDinnerEntreeFor:dinnerTime]];
    [items addObject:[HVDietaryIntake makeDinnerVeggiesFor:dinnerTime]];
    [items addObject:[HVDietaryIntake makeDinnerDessertFor:dinnerTime]];

    return items;

LError:
    return nil;
}

+(HVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [HVDietaryIntake createRandomForDay:date]; // No metric specific units
}

+(HVItem *)makeBreakfastFor:(HVDateTime *)breakfastTime
{    
    HVItem* breakfast = [HVDietaryIntake
                         createRandomValuesForFood:[HVCodableValue fromText:@"BreakfastFood"]
                         meal:[HVDietaryIntake mealCodeForBreakfast]
                         onDate:breakfastTime];
    
    return breakfast;
}

+(HVItem *)makeLunchEntreeFor:(HVDateTime *)lunchTime
{
    HVItem* lunch = [HVDietaryIntake
                     createRandomValuesForFood:[HVCodableValue fromText:@"Lunch entree"]
                     meal:[HVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(HVItem *)makeLunchVeggiesFor:(HVDateTime *)lunchTime
{
    HVItem* lunch = [HVDietaryIntake
                     createRandomValuesForFood:[HVCodableValue fromText:@"Lunch Veggies"]
                     meal:[HVDietaryIntake mealCodeForLunch]
                     onDate:lunchTime];
    return lunch;
}

+(HVItem *)makeDinnerEntreeFor:(HVDateTime *)dinnerTime
{
    HVItem* dinner = [HVDietaryIntake
                      createRandomValuesForFood:[HVCodableValue fromText:@"Dinner entree"]
                      meal:[HVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;
}

+(HVItem *)makeDinnerVeggiesFor:(HVDateTime *)dinnerTime
{
    HVItem* dinner = [HVDietaryIntake
                      createRandomValuesForFood:[HVCodableValue fromText:@"Dinner Veggies"]
                      meal:[HVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(HVItem *)makeDinnerDessertFor:(HVDateTime *)dinnerTime
{
    HVItem* dinner = [HVDietaryIntake
                      createRandomValuesForFood:[HVCodableValue fromText:@"Dinner Dessert"]
                      meal:[HVDietaryIntake mealCodeForDinner]
                      onDate:dinnerTime];
    return dinner;    
}

+(HVVocabIdentifier *)getVocabForMeals
{
    if (s_vocabForMeals == nil)
    {
        s_vocabForMeals = [HVDietaryIntake vocabForMeals];
    }
    
    return s_vocabForMeals;
}

@end

@implementation HVDietaryIntake (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ [%.0f calories] %@", self.foodItem.description, self.calories.caloriesValue, self.meal ? self.meal.description : c_emptyString];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
