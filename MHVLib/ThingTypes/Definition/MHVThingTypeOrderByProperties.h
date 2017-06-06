//
//  MHVThingTypeOrderByProperties.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"

@class MHVThingTypeProperty;

@interface MHVThingTypeOrderByProperties : MHVType

@property (nonatomic, strong, readonly) NSArray<MHVThingTypeProperty *> *properties;

@end
