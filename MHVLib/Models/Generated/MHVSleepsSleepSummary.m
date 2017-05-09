#import "MHVSleepsSleepSummary.h"

@implementation MHVSleepsSleepSummary

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"bedtime": @"bedtime", @"fallAsleepDuration": @"fallAsleepDuration", @"wakeupTime": @"wakeupTime", @"sleepDuration": @"sleepDuration" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"bedtime": @"bedtime",
            @"fallAsleepDuration": @"fallAsleepDuration",
            @"wakeupTime": @"wakeupTime",
            @"sleepDuration": @"sleepDuration"
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

  NSArray *optionalProperties = @[@"bedtime", @"fallAsleepDuration", @"wakeupTime", @"sleepDuration"];
  return [optionalProperties containsObject:propertyName];
}

@end
