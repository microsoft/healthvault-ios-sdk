#import "MHVOnboardingRequest.h"

@implementation MHVOnboardingRequest

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"friendlyName": @"friendlyName", @"applicationPatientId": @"applicationPatientId", @"secretQuestion": @"secretQuestion", @"secretAnswer": @"secretAnswer", @"firstName": @"firstName", @"lastName": @"lastName", @"email": @"email", @"zipCode": @"zipCode", @"state": @"state", @"country": @"country", @"birthday": @"birthday", @"gender": @"gender", @"weight": @"weight", @"height": @"height", @"actionPlanTemplateIds": @"actionPlanTemplateIds", @"conditions": @"conditions" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"friendlyName": @"friendlyName",
            @"applicationPatientId": @"applicationPatientId",
            @"secretQuestion": @"secretQuestion",
            @"secretAnswer": @"secretAnswer",
            @"firstName": @"firstName",
            @"lastName": @"lastName",
            @"email": @"email",
            @"zipCode": @"zipCode",
            @"state": @"state",
            @"country": @"country",
            @"birthday": @"birthday",
            @"gender": @"gender",
            @"weight": @"weight",
            @"height": @"height",
            @"actionPlanTemplateIds": @"actionPlanTemplateIds",
            @"conditions": @"conditions"
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

  NSArray *optionalProperties = @[@"friendlyName", @"applicationPatientId", @"secretQuestion", @"secretAnswer", @"firstName", @"lastName", @"email", @"zipCode", @"state", @"country", @"birthday", @"gender", @"weight", @"height", @"actionPlanTemplateIds", @"conditions"];
  return [optionalProperties containsObject:propertyName];
}

@end
