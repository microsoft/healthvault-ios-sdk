//
//  MHVThingTypeDefinitionRequestParameters.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"
#import "MHVThingConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVThingTypeDefinitionRequestParameters : MHVType

- (instancetype)initWithTypeIds:(NSArray<NSString *> *_Nullable)typeIds
                       sections:(MHVThingTypeSections)sections
                     imageTypes:(NSArray<NSString *> *_Nullable)imageTypes
          lastClientRefreshDate:(NSDate *_Nullable)lastClientRefreshDate;

@end

NS_ASSUME_NONNULL_END
