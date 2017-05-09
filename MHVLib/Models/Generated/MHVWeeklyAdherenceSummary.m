#import "MHVWeeklyAdherenceSummary.h"

@implementation MHVWeeklyAdherenceSummary

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"weekStart": @"weekStart", @"completions": @"completions", @"intendedCompletions": @"intendedCompletions", @"intendedOccurrences": @"intendedOccurrences", @"manualTrackedOccurrences": @"manualTrackedOccurrences", @"automaticTrackedOccurrences": @"automaticTrackedOccurrences", @"automaticTrackedOccurrenceEvidence": @"automaticTrackedOccurrenceEvidence" }];
}
 */

+ (NSDictionary *)propertyNameMap
{
    static dispatch_once_t once;
    static NSMutableDictionary *names = nil;
    dispatch_once(&once, ^{
        names = [[super propertyNameMap] mutableCopy];
        [names addEntriesFromDictionary:@{
            @"weekStart": @"weekStart",
            @"completions": @"completions",
            @"intendedCompletions": @"intendedCompletions",
            @"intendedOccurrences": @"intendedOccurrences",
            @"manualTrackedOccurrences": @"manualTrackedOccurrences",
            @"automaticTrackedOccurrences": @"automaticTrackedOccurrences",
            @"automaticTrackedOccurrenceEvidence": @"automaticTrackedOccurrenceEvidence"
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

  NSArray *optionalProperties = @[@"weekStart", @"completions", @"intendedCompletions", @"intendedOccurrences", @"manualTrackedOccurrences", @"automaticTrackedOccurrences", @"automaticTrackedOccurrenceEvidence"];
  return [optionalProperties containsObject:propertyName];
}

@end
