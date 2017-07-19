//
//  MHVPredicate.m
//  healthvault-ios-sdk
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MHVCacheQuery.h"
#import <objc/runtime.h>
#import "MHVValidator.h"
#import "MHVStringExtensions.h"
#import "NSArray+Utils.h"
#import "MHVThingQuery.h"
#import "NSError+MHVError.h"

static NSDictionary *kPropertyMap;
static NSDictionary *kOperatorMap;
static NSDictionary *kIgnoreMap;
static NSDictionary *kSubPredicatesMap;
static NSString *const kPredicateVariable = @"predicateVariable";

@implementation MHVCacheQuery

+ (void)initialize
{
    kPropertyMap = @{
                     @"thingIDs" : @"thingId",
                     @"thingID" : @"thingId",
                     @"version" : @"version",
                     @"typeIDs" : @"typeId",
                     @"clientIDs" : @"clientId",
                     @"effectiveDateMin" : @"effectiveDate",
                     @"effectiveDateMax" : @"effectiveDate",
                     @"createDateMin" : @"createDate",
                     @"createDateMax" : @"createDate",
                     @"updateDateMin" : @"updateDate",
                     @"updateDateMax" : @"updateDate",
                     @"createdByAppID" : @"createdByAppID",
                     @"createdByPersonID" : @"createdByPersonID",
                     @"updatedByAppID" : @"updatedByAppID",
                     @"updatedByPersonID" : @"updatedByPersonID"
                     };
    
    kOperatorMap = @{
                     @"thingIDs" : @(NSEqualToPredicateOperatorType),
                     @"thingID" : @(NSEqualToPredicateOperatorType),
                     @"version" : @(NSEqualToPredicateOperatorType),
                     @"typeIDs" : @(NSEqualToPredicateOperatorType),
                     @"clientIDs" : @(NSEqualToPredicateOperatorType),
                     @"effectiveDateMin" : @(NSGreaterThanOrEqualToPredicateOperatorType),
                     @"effectiveDateMax" : @(NSLessThanOrEqualToPredicateOperatorType),
                     @"createDateMin" : @(NSGreaterThanOrEqualToPredicateOperatorType),
                     @"createDateMax" : @(NSLessThanOrEqualToPredicateOperatorType),
                     @"updateDateMin" : @(NSGreaterThanOrEqualToPredicateOperatorType),
                     @"updateDateMax" : @(NSLessThanOrEqualToPredicateOperatorType),
                     @"createdByAppID" : @(NSEqualToPredicateOperatorType),
                     @"createdByPersonID" : @(NSEqualToPredicateOperatorType),
                     @"updatedByAppID" : @(NSEqualToPredicateOperatorType),
                     @"updatedByPersonID" : @(NSEqualToPredicateOperatorType)
                     };
    
    kIgnoreMap = @{
                   @"shouldUseCachedResults" : @"ignore",
                   @"keys" : @"ignore",
                   @"filters" : @"ignore",
                   @"view" : @"ignore",
                   };

    kSubPredicatesMap = @{
                          @"keys" : @(YES),
                          @"filters" : @(YES),
                          };
}

- (instancetype)initWithQuery:(MHVThingQuery *)query
{
    MHVASSERT_PARAMETER(query);
    
    self = [super init];
    {
        if (self)
        {
            [self setPredicateWithQuery:query];
        }
    }
    
    return self;
}

- (BOOL)canCreateWithQuery:(MHVThingQuery *)query
{
    // If the query is nil we cannot create a predicate
    if (!query)
    {
        _error = [NSError error:[NSError MHVInvalidThingQuery] withDescription:@"MHVThingCacheQuery was initialized with a nil query parameter."];
        return NO;
    }
    
    if (!query.shouldUseCachedResults)
    {
        return NO;
    }
    
    // Ensure only one collection has elements
    NSUInteger colletionCounter = (query.thingIDs.count > 0) ? 1 : 0;
    colletionCounter += (query.keys.count > 0) ? 1 : 0;
    colletionCounter += (query.clientIDs.count > 0) ? 1 : 0;
    if (colletionCounter > 1)
    {
        _error = [NSError error:[NSError MHVInvalidThingQuery] withDescription:@"thingIDs, keys, and clientIDs are mutually exclusive. Only one of these collections can contain elements for a given query."];
        return NO;
    }
    
    // The cache does not support xpath predicates
    for (MHVThingFilter *filter in query.filters)
    {
        if (![NSString isNilOrEmpty:filter.xpath])
        {
            return NO;
        }
    }
    
    // The cache only supports MHVThingSection_Standard section
    if (query.view.sections != MHVThingSection_Standard &&
        query.view.sections != MHVThingSection_Data &&
        query.view.sections != MHVThingSection_Core)
    {
        return NO;
    }
    
    if (![NSArray isNilOrEmpty:query.view.transforms])
    {
        return NO;
    }
    
    if (![NSArray isNilOrEmpty:query.view.typeVersions])
    {
        return NO;
    }
    
    return YES;
}

- (void)setPredicateWithQuery:(MHVThingQuery *)query
{
    _canQueryCache = [self canCreateWithQuery:query];
    
    if (!self.canQueryCache)
    {
        return;
    }
    
    _predicate = [self predicateForObject:query];
}

- (NSPredicate *)predicateWithPropertyName:(NSString *)propertyName
                                  variable:(NSObject *)variable
{
 
    NSNumber *operator = kOperatorMap[propertyName];
    NSString *keyPath = kPropertyMap[propertyName];
    
    if (!variable || !operator || kIgnoreMap[propertyName])
    {
        return nil;
    }
    
    NSPredicate *predicateTemplate = [NSComparisonPredicate
                                      predicateWithLeftExpression:[NSExpression expressionForKeyPath:keyPath]
                                      rightExpression:[NSExpression expressionForVariable:kPredicateVariable]
                                      modifier:NSDirectPredicateModifier
                                      type:operator.unsignedIntegerValue
                                      options:0];
    
    return [predicateTemplate predicateWithSubstitutionVariables:@{
                                                                   kPredicateVariable : variable
                                                                   }];
}

- (NSPredicate *)predicateWithPropertyName:(NSString *)propertyName
                                 variables:(NSArray *)variables
{
    if ([NSArray isNilOrEmpty:variables])
    {
        return nil;
    }
    
    NSMutableArray<NSPredicate *> *predicates = [NSMutableArray new];
    
    for (NSString *variable in variables)
    {
        NSPredicate *predicate = [self predicateWithPropertyName:propertyName
                                                        variable:variable];
        
        if (predicate)
        {
            [predicates addObject:predicate];
        }
    }
    
    if (predicates.count < 1)
    {
        return nil;
    }
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
}

- (NSPredicate *)predicateForObject:(NSObject *)object
{
    NSMutableArray<NSPredicate *> *predicates = [NSMutableArray new];
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        
        NSString *propertyName = [NSString stringWithUTF8String:name];
        
        if (propertyName)
        {
            id value = [object valueForKey:propertyName];
            
            if ([propertyName isEqualToString:@"limit"])
            {
                _fetchLimit = ((NSNumber *)value).integerValue;
                
                continue;
            }
            else if ([propertyName isEqualToString:@"offset"])
            {
                _fetchOffset = ((NSNumber *)value).integerValue;
                
                continue;
            }
            
            NSPredicate *predicate = nil;
            
            Class propertyClass;
            
            const char *type = property_getAttributes(property);
            NSString *typeString = [NSString stringWithUTF8String:type];
            NSArray *attributes = [typeString componentsSeparatedByString:@","];
            NSString *typeAttribute = [attributes objectAtIndex:0];
            
            if ([typeAttribute hasPrefix:@"T@"])
            {
                NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
                propertyClass = NSClassFromString(typeClassName);
            }
            
            if (kSubPredicatesMap[propertyName])
            {
                NSMutableArray<NSPredicate *> *subPredicates = [NSMutableArray new];
                
                for (MHVType *type in value)
                {
                    NSPredicate *subPredicate = [self predicateForObject:type];
                    
                    if (subPredicate)
                    {
                        [subPredicates addObject:subPredicate];
                    }
                }
                
                if (subPredicates.count > 0)
                {
                    predicate = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];
                }
            }
            else if ([propertyClass isSubclassOfClass:[NSArray class]])
            {
                predicate = [self predicateWithPropertyName:propertyName
                                                  variables:value];
            }
            else
            {
                predicate = [self predicateWithPropertyName:propertyName
                                                   variable:value];
            }
            
            if (predicate)
            {
                [predicates addObject:predicate];
            }
        }
    }
    
    free(properties);
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

@end
