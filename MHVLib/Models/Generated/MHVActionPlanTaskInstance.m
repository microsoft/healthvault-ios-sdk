#import "MHVActionPlanTaskInstance.h"

@implementation MHVActionPlanTaskInstance

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"_id": @"id", @"status": @"status", @"startDate": @"startDate", @"endDate": @"endDate", @"organizationId": @"organizationId", @"organizationName": @"organizationName", @"name": @"name", @"shortDescription": @"shortDescription", @"longDescription": @"longDescription", @"imageUrl": @"imageUrl", @"thumbnailImageUrl": @"thumbnailImageUrl", @"taskType": @"taskType", @"trackingPolicy": @"trackingPolicy", @"signupName": @"signupName", @"associatedPlanId": @"associatedPlanId", @"associatedObjectiveIds": @"associatedObjectiveIds", @"completionType": @"completionType", @"frequencyTaskCompletionMetrics": @"frequencyTaskCompletionMetrics", @"scheduledTaskCompletionMetrics": @"scheduledTaskCompletionMetrics" }];
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
            @"startDate": @"startDate",
            @"endDate": @"endDate",
            @"organizationId": @"organizationId",
            @"organizationName": @"organizationName",
            @"name": @"name",
            @"shortDescription": @"shortDescription",
            @"longDescription": @"longDescription",
            @"imageUrl": @"imageUrl",
            @"thumbnailImageUrl": @"thumbnailImageUrl",
            @"taskType": @"taskType",
            @"trackingPolicy": @"trackingPolicy",
            @"signupName": @"signupName",
            @"associatedPlanId": @"associatedPlanId",
            @"associatedObjectiveIds": @"associatedObjectiveIds",
            @"completionType": @"completionType",
            @"frequencyTaskCompletionMetrics": @"frequencyTaskCompletionMetrics",
            @"scheduledTaskCompletionMetrics": @"scheduledTaskCompletionMetrics"
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
            
              @"trackingPolicy": [MHVActionPlanTrackingPolicy class],

              @"frequencyTaskCompletionMetrics": [MHVActionPlanFrequencyTaskCompletionMetrics class],

              @"scheduledTaskCompletionMetrics": [MHVActionPlanScheduledTaskCompletionMetrics class]
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

  NSArray *optionalProperties = @[@"_id", @"status", @"startDate", @"endDate", @"organizationId", @"organizationName", @"name", @"shortDescription", @"longDescription", @"imageUrl", @"thumbnailImageUrl", @"taskType", @"trackingPolicy", @"signupName", @"associatedPlanId", @"associatedObjectiveIds", @"completionType", @"frequencyTaskCompletionMetrics", @"scheduledTaskCompletionMetrics"];
  return [optionalProperties containsObject:propertyName];
}

@end
