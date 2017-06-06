//
//  MHVThingTypeProperty.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"

@protocol MHVItemTypePropertyConverterProtocol;

@interface MHVThingTypeProperty : MHVType

@property (nonatomic, strong, readonly, nullable) NSString *name;

@property (nonatomic, strong, readonly, nullable) NSString *type;

@property (nonatomic, strong, readonly, nullable) NSString *xpath;

@property (nonatomic, strong, readonly, nullable) id<MHVItemTypePropertyConverterProtocol> converter;

@end
