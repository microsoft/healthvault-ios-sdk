//
//  MHVPendingMethod.m
//  Pods
//
//  Created by Nathan Malubay on 7/11/17.
//
//

#import "MHVPendingMethod.h"

@implementation MHVPendingMethod

@synthesize name = _name;
@synthesize version = _version;
@synthesize parameters = _parameters;
@synthesize recordId = _recordId;
@synthesize correlationId = _correlationId;

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                     method:(MHVMethod *)method
{
    self = [super init];
    
    if (self)
    {
        _originalRequestDate = originalRequestDate;
        _name = method.name;
        _version = method.version;
        _parameters = method.parameters;
        _recordId = method.recordId;
        _correlationId = method.correlationId;

    }
    
    return self;
}

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                 methodName:(NSString *)methodName
{
    self = [super init];
    
    if (self)
    {
        _originalRequestDate = originalRequestDate;
        _name = methodName;
    }
    
    return self;
}

@end
