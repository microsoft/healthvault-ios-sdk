//
//  MHVThingTypeDefinition.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"

@class MHVThingTypeVersionInfo, MHVBool;

@interface MHVThingTypeDefinition : MHVType

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSUUID *typeId;

@property (nonatomic, strong, readonly) NSString *xmlSchemaDefinition;

@property (nonatomic, strong, readonly) MHVBool *isCreatable;

@property (nonatomic, strong, readonly) MHVBool *isImmutable;

@property (nonatomic, strong, readonly) MHVBool *isSingletonType;

@property (nonatomic, strong, readonly) MHVBool *allowReadOnly;

@property (nonatomic, strong, readonly) NSArray<MHVThingTypeVersionInfo *> *versions;

@property (nonatomic, strong, readonly) NSString *effectiveDateXPath;

@property (nonatomic, strong, readonly) NSString *updatedEndDateXPath;

@end
