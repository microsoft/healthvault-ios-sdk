#import "MHVSleepsSleep.h"

@implementation MHVSleepsSleep

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"sleepId": @"sleepId", @"userId": @"userId", @"startTime": @"startTime", @"endTime": @"endTime", @"sleepSummary": @"sleepSummary", @"wakeState": @"wakeState", @"lastModifiedBy": @"lastModifiedBy", @"createdBy": @"createdBy" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"sleepId": @"sleepId",
            @"userId": @"userId",
            @"startTime": @"startTime",
            @"endTime": @"endTime",
            @"sleepSummary": @"sleepSummary",
            @"wakeState": @"wakeState",
            @"lastModifiedBy": @"lastModifiedBy",
            @"createdBy": @"createdBy"
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
            
              @"sleepSummary": [MHVSleepsSleepSummary class],

              @"lastModifiedBy": [MHVAudit class],

              @"createdBy": [MHVAudit class]
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

  NSArray *optionalProperties = @[@"sleepId", @"userId", @"startTime", @"endTime", @"sleepSummary", @"wakeState", @"lastModifiedBy", @"createdBy"];
  return [optionalProperties containsObject:propertyName];
}

@end
