//
//  MHVThingDataTypedFeatures.m
//  SDKFeatures
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

#import "MHVThingDataTypedFeatures.h"
#import "MHVTypeViewController.h"
#import "MHVUIAlert.h"

@interface MHVThingDataTypedFeatures ()

@property (nonatomic, strong) id<MHVConnectionProtocol> connection;

@end

@implementation MHVThingDataTypedFeatures

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super initWithTitle:title];
    
    if (self)
    {
        __weak __typeof__(self)weakSelf = self;
        
        [self addFeature:@"View XSD Schema" andAction:^
        {
            [weakSelf fetchAndDisplaySchema];
        }];
        
        _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    }
    
    return self;
}

- (void)fetchAndDisplaySchema
{
    [self.controller.statusLabel showBusy];
    
    __block NSString *typeId = [self.typeClass typeID];
    
    [self.connection.platformClient getHealthRecordThingTypeDefinitionsWithTypeIds:@[typeId]
                                                                          sections:MHVThingTypeSectionsXsd
                                                                        imageTypes:nil
                                                             lastClientRefreshDate:nil
                                                                        completion:^(NSDictionary<NSString *,MHVThingTypeDefinition *> * _Nullable definitions, NSError * _Nullable error)
     {
         [self.controller.statusLabel clearStatus];
         
         NSString *displayString;
         
         if (error)
         {
             displayString = error.localizedDescription;
         }
         else
         {
             MHVThingTypeDefinition *definition = [definitions objectForKey:typeId];
             
             displayString = definition.xmlSchemaDefinition;
         }
         
         [MHVUIAlert showInformationalMessage:displayString];
         
     }];
}

@end
