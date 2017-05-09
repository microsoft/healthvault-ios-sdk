#import "MHVGoalRecommendationInstance.h"

@implementation MHVGoalRecommendationInstance

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"_id": @"id", @"organizationId": @"organizationId", @"organizationName": @"organizationName", @"acknowledged": @"acknowledged", @"expirationDate": @"expirationDate", @"associatedGoal": @"associatedGoal" }];
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
            @"organizationId": @"organizationId",
            @"organizationName": @"organizationName",
            @"acknowledged": @"acknowledged",
            @"expirationDate": @"expirationDate",
            @"associatedGoal": @"associatedGoal"
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
            
              @"associatedGoal": [MHVGoal class]
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

  NSArray *optionalProperties = @[@"_id", @"organizationId", @"organizationName", @"acknowledged", @"expirationDate", @"associatedGoal"];
  return [optionalProperties containsObject:propertyName];
}

@end
