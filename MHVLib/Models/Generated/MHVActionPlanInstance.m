#import "MHVActionPlanInstance.h"

@implementation MHVActionPlanInstance

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"_id": @"id", @"status": @"status", @"organizationId": @"organizationId", @"organizationName": @"organizationName", @"associatedTasks": @"associatedTasks", @"name": @"name", @"_description": @"description", @"imageUrl": @"imageUrl", @"thumbnailImageUrl": @"thumbnailImageUrl", @"category": @"category", @"objectives": @"objectives" }];
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
            @"status": @"status",
            @"organizationId": @"organizationId",
            @"organizationName": @"organizationName",
            @"associatedTasks": @"associatedTasks",
            @"name": @"name",
            @"_description": @"description",
            @"imageUrl": @"imageUrl",
            @"thumbnailImageUrl": @"thumbnailImageUrl",
            @"category": @"category",
            @"objectives": @"objectives"
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
            
              @"associatedTasks": [MHVActionPlanTaskInstance class],

              @"objectives": [MHVObjective class]
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

  NSArray *optionalProperties = @[@"_id", @"status", @"organizationId", @"organizationName", @"associatedTasks", @"name", @"_description", @"imageUrl", @"thumbnailImageUrl", @"category", @"objectives"];
  return [optionalProperties containsObject:propertyName];
}

@end
