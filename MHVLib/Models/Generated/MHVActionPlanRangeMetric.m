#import "MHVActionPlanRangeMetric.h"

@implementation MHVActionPlanRangeMetric

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"propertyName": @"propertyName", @"valueType": @"valueType", @"maxTarget": @"maxTarget", @"minTarget": @"minTarget", @"propertyXPath": @"propertyXPath" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"propertyName": @"propertyName",
            @"valueType": @"valueType",
            @"maxTarget": @"maxTarget",
            @"minTarget": @"minTarget",
            @"propertyXPath": @"propertyXPath"
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

  NSArray *optionalProperties = @[@"propertyName", @"valueType", @"maxTarget", @"minTarget", @"propertyXPath"];
  return [optionalProperties containsObject:propertyName];
}

@end
