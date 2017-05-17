//
//  MHVServiceDefinitionRequestParameters.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/17/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"
#import "MHVPlatformConstants.h"

@interface MHVServiceDefinitionRequestParameters : MHVType

- (instancetype)initWithInfoSections:(MHVServiceInfoSections)infoSections
                     lastUpdatedTime:(NSDate *)lastUpdatedTime;

@end
