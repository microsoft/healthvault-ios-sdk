#import "MHVActionPlanTaskTracking.h"

@implementation MHVActionPlanTaskTracking

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"_id": @"id", @"trackingType": @"trackingType", @"timeZoneOffset": @"timeZoneOffset", @"trackingDateTime": @"trackingDateTime", @"creationDateTime": @"creationDateTime", @"trackingStatus": @"trackingStatus", @"occurrenceStart": @"occurrenceStart", @"occurrenceEnd": @"occurrenceEnd", @"completionStart": @"completionStart", @"completionEnd": @"completionEnd", @"taskId": @"taskId", @"feedback": @"feedback", @"evidence": @"evidence" }];
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
            @"trackingType": @"trackingType",
            @"timeZoneOffset": @"timeZoneOffset",
            @"trackingDateTime": @"trackingDateTime",
            @"creationDateTime": @"creationDateTime",
            @"trackingStatus": @"trackingStatus",
            @"occurrenceStart": @"occurrenceStart",
            @"occurrenceEnd": @"occurrenceEnd",
            @"completionStart": @"completionStart",
            @"completionEnd": @"completionEnd",
            @"taskId": @"taskId",
            @"feedback": @"feedback",
            @"evidence": @"evidence"
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
            
              @"evidence": [MHVActionPlanTaskTrackingEvidence class]
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

  NSArray *optionalProperties = @[@"_id", @"trackingType", @"timeZoneOffset", @"trackingDateTime", @"creationDateTime", @"trackingStatus", @"occurrenceStart", @"occurrenceEnd", @"completionStart", @"completionEnd", @"taskId", @"feedback", @"evidence"];
  return [optionalProperties containsObject:propertyName];
}

@end
