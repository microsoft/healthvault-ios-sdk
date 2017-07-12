//
//  MHVPendingMethod.h
//  Pods
//
//  Created by Nathan Malubay on 7/11/17.
//
//

#import "MHVMethod.h"

@interface MHVPendingMethod : MHVMethod

@property (nonatomic, strong, readonly) NSDate *originalRequestDate;

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                     method:(MHVMethod *)method;

- (instancetype)initWithOriginalRequestDate:(NSDate *)originalRequestDate
                                 methodName:(NSString *)methodName;

@end
