#import "MHVGoal.h"

@implementation MHVGoal

+ (BOOL)shouldValidateProperties
{
    return YES;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // initialize property's default value, if any
    
  }
  return self;
}


/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.

+ (JSONKeyMapper *)keyMapper {
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"_id": @"id", @"name": @"name", @"_description": @"description", @"startDate": @"startDate", @"endDate": @"endDate", @"goalType": @"goalType", @"recurrenceMetrics": @"recurrenceMetrics", @"range": @"range", @"additionalRanges": @"additionalRanges" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"_id": @"id",
            @"name": @"name",
            @"_description": @"description",
            @"startDate": @"startDate",
            @"endDate": @"endDate",
            @"goalType": @"goalType",
            @"recurrenceMetrics": @"recurrenceMetrics",
            @"range": @"range",
            @"additionalRanges": @"additionalRanges"
        }];
    });
    return names;
}


+ (NSDictionary *)objectParametersMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *types = nil;
    dispatch_once(&once, ^{
        types = [[super objectParametersMap] mutableCopy];
        [types addEntriesFromDictionary:@{
            
              @"recurrenceMetrics": [MHVGoalRecurrenceMetrics class],

              @"range": [MHVGoalRange class],

              @"additionalRanges": [MHVGoalRange class]
        }];
    });
    return types;
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"_id", @"name", @"_description", @"startDate", @"endDate", @"goalType", @"recurrenceMetrics", @"range", @"additionalRanges"];
  return [optionalProperties containsObject:propertyName];
}

@end
