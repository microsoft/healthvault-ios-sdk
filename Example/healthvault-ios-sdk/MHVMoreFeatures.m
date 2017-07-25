//
//  MHVMoreFeatures.m
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

#import "MHVMoreFeatures.h"
#import "MHVTypeListViewController.h"
#import "MHVUIAlert.h"

@implementation MHVMoreFeatures

- (void)disconnectApp
{
    [MHVUIAlert showYesNoPromptWithMessage:@"Are you sure you want to disconnect this application from HealthVault?\r\nIf you click Yes, you will need to re-authorize the next time you run it."
                                completion:^(BOOL selectedYes)
     {
         if (selectedYes)
         {
             [self.listController.statusLabel showBusy];
             //
             // REMOVE RECORD AUTHORIZATION.
             //
             id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
             
             [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error)
              {
                  [[NSOperationQueue mainQueue] addOperationWithBlock:^
                   {
                       [self.listController.navigationController popToRootViewControllerAnimated:YES];
                   }];
              }];
         }
     }];
}

- (void)getServiceDefinition
{
    [self.listController.statusLabel showBusy];
    
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.platformClient getServiceDefinitionWithWithLastUpdatedTime:nil
                                                          responseSections:MHVServiceInfoSectionsAll
                                                                completion:^(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error)
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             MHVConfigurationEntry* configEntry = [serviceDefinition.platform.config objectAtIndex:0];
             MHVConfigurationEntry* configEntry2 = [serviceDefinition.platform.config objectAtIndex:1];
             NSMutableString* output = [[NSMutableString alloc] init];
             
             [self appendToString:output lines:17, @"Some data from ServiceDefinition",
              @"[PlatformUrl]", serviceDefinition.platform.url,
              @"[PlatformVersion]", serviceDefinition.platform.version,
              @"[ShellUrl]", serviceDefinition.shell.url,
              @"[ShellRedirect]", serviceDefinition.shell.redirectUrl,
              @"[Example Config Entries]",
              configEntry.key, @"==", configEntry.value, @"==========",
              configEntry2.key, @"==", configEntry2.value];
             
             [MHVUIAlert showInformationalMessage:output];
         }
         
         
         [self.listController.statusLabel clearStatus];
     }];
}

- (void)demonstrateApplicationSettings
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    NSString *appSettings = [NSString stringWithFormat:@"<date>%@</date>", [NSDate date]];
    
    [connection.personClient setApplicationSettings:appSettings
                                         completion:^(NSError * _Nullable errorForSet)
     {
         if (errorForSet)
         {
             [MHVUIAlert showInformationalMessage:errorForSet.localizedDescription];
             return;
         }
         
         [connection.personClient getApplicationSettingsWithCompletion:^(NSString *_Nullable settings, NSError * _Nullable errorForGet)
          {
              if (errorForGet)
              {
                  [MHVUIAlert showInformationalMessage:errorForGet.localizedDescription];
              }
              else
              {
                  NSMutableString *result = [NSMutableString new];
                  [result appendFormat:@"Wrote: %@\n\n", appSettings];
                  [result appendFormat:@"Read: %@", settings];
                  
                  [MHVUIAlert showInformationalMessage:result];
              }
          }];
     }];
}

- (void)getPersonInfo
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.personClient getPersonInfoWithCompletion:^(MHVPersonInfo * _Nullable person, NSError * _Nullable error)
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             NSMutableString *result = [NSMutableString new];
             [result appendFormat:@"Name: %@\n\n", person.name];
             [result appendFormat:@"ID: %@...\n\n", [person.ID.UUIDString substringToIndex:7]];
             [result appendFormat:@"AppSettingsXml: %@", person.applicationSettings];
             
             [MHVUIAlert showInformationalMessage:result];
         }
     }];
}

- (void)getAuthorizedRecords
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    NSMutableArray *recordIds = [NSMutableArray new];
    
    for (MHVRecord *record in connection.personInfo.records)
    {
        [recordIds addObject:record.ID];
    }
    
    [connection.personClient getAuthorizedRecordsWithRecordIds:recordIds
                                                    completion:^(NSArray<MHVRecord *> *_Nullable records, NSError * _Nullable error)
    {
        if (error)
        {
            [MHVUIAlert showInformationalMessage:error.localizedDescription];
        }
        else
        {
            NSMutableString *result = [NSMutableString new];
            [result appendFormat:@"%li Record(s):\n", records.count];
            
            for (MHVRecord *record in records)
            {
                [result appendString:@"\n"];
                [result appendFormat:@"Name: %@\n", record.name];
                [result appendFormat:@"ID: %@...\n", [record.ID.UUIDString substringToIndex:7]];
            }
            
            [MHVUIAlert showInformationalMessage:result];
        }
    }];
}

- (void)getAuthorizedPeople
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.personClient getAuthorizedPeopleWithCompletion:^(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError * _Nullable error)
    {
        if (error)
        {
            [MHVUIAlert showInformationalMessage:error.localizedDescription];
        }
        else
        {
            NSMutableString *result = [NSMutableString new];
            [result appendFormat:@"%li Authorized People:\n", personInfos.count];
            
            for (MHVPersonInfo *info in personInfos)
            {
                [result appendString:@"\n"];
                [result appendFormat:@"Name: %@\n", info.name];
                [result appendFormat:@"ID: %@...\n", [info.ID.UUIDString substringToIndex:7]];
            }
            
            [MHVUIAlert showInformationalMessage:result];
        }
    }];
}

- (void)getRecordOperations
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.thingClient getRecordOperations:1
                                          recordId:connection.personInfo.selectedRecordID
                                        completion:^(MHVGetRecordOperationsResult * _Nullable result, NSError * _Nullable error)
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             NSMutableString *string = [NSMutableString new];
             [string appendFormat:@"%li Operations:\n", result.operations.count];

             MHVRecordOperation *operation = result.operations.lastObject;
             [string appendString:@"Last\n"];
             [string appendFormat:@"Operation: %@\n", operation.operation];
             [string appendFormat:@"ID: %@...\n", [operation.thingId substringToIndex:7]];
             
             MHVThing *thing = [[MHVThing alloc] initWithType:operation.typeId];
             [string appendFormat:@"Type: %@\n", NSStringFromClass([thing.data.typed class])];
             
             [MHVUIAlert showInformationalMessage:string];
         }
     }];
}

- (void)authorizeAdditionalRecords
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection authorizeAdditionalRecordsWithViewController:self.listController
                                                  completion:^(NSError * _Nullable error)
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             // Popping to the root view controller will reload to the updated list of authorized records
             [[NSOperationQueue mainQueue] addOperationWithBlock:^
              {
                  [self.listController.navigationController popToRootViewControllerAnimated:YES];
              }];
         }
     }];
}

- (void)appendToString:(NSMutableString *)string lines:(int)count, ...
{
    va_list args;
    va_start(args, count);
    
    for (int i = 0; i < count; ++i)
    {
        NSString *str = va_arg(args, NSString *);
        if (str && ![str isEqualToString:@""])
        {
            [string appendString:string];
            [string appendString:@"\n\r"];
        }
    }
    
    va_end(args);
}

@end
