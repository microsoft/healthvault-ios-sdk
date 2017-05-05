//
//  MHVUser.h
//  MHVLib
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MHVTypes.h"
#import "XLib.h"
#import "HealthVaultService.h"

//
// The user of your HealthVault application
// 
@interface MHVUser : XSerializableType
{
@private
    NSString * m_name;
    MHVRecordCollection *m_records;
    NSInteger m_currentIndex;
    NSString* m_environment;
    NSString* m_instanceID;
}

//
// The user's display name in HealthVault
//
@property (readwrite, nonatomic, strong) NSString* name;
//
// Records this user is authorized to access
//
@property (readwrite, nonatomic, strong) MHVRecordCollection* records;
@property (readonly, nonatomic) BOOL hasRecords; // true if user has authorized records
//
// The records the application is currently working with
// To change the current record, set the currentRecordIndex property
//
@property (readwrite, nonatomic) NSInteger currentRecordIndex;
@property (readonly, nonatomic, strong) MHVRecord* currentRecord;

//
// Which service environment this user set up their app to work with
//
@property (readwrite, nonatomic, strong) NSString* environment;

@property (readwrite, nonatomic, strong) NSString* instanceID;

@property (readonly, nonatomic) BOOL hasEnvironment;
@property (readonly, nonatomic) BOOL hasInstanceID;

//-------------------------
//
// Methods
//
//-------------------------

-(id) initFromLegacyRecords:(NSArray *) recordArray;  // Infrastructure - will eventually go away
//
// Refresh the list of authorized records - in case there were changes made using the HealthVault Shell
// It is possible that when this returns, you no longer have any authorized records
//
-(MHVTask *) refreshAuthorizedRecords:(MHVTaskCompletion) callback;
//
// Authorize additional records for this application to work with
// It is possible that when this returns, you no longer have any authorized records
//
-(MHVTask *) authorizeAdditionalRecords:(UIViewController *) parentController andCallback:(MHVTaskCompletion) callback;
//
// Remove authorization for the given record
//
-(MHVTask *) removeAuthForRecord:(MHVRecord *) record withCallback:(MHVTaskCompletion) callback;
//
// Refresh personal images for each record
// Automatically store the downloaded image in local storage
//
-(MHVTask *) downloadRecordImageFor:(MHVRecord *) record withCallback:(MHVTaskCompletion) callback;


-(void) clear;

-(MHVClientResult *) validate;

//
// For internal use only. 
//
-(BOOL) updateWithLegacyRecords:(NSArray *) records;
-(void) configureCurrentRecordForService:(HealthVaultService *) service;
-(void) clearRecordsForService:(HealthVaultService *) service;

@end