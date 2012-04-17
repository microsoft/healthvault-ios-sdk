//
//  HVUser.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVTypes.h"
#import "XLib.h"
#import "HealthVaultService.h"

//
// The user of your HealthVault application
// 
@interface HVUser : XSerializableType
{
@private
    NSString * m_name;
    HVRecordCollection *m_records;
    NSInteger m_currentIndex;
}

-(id) initFromLegacyRecords:(NSArray *) recordArray;

//
// The user's display name in HealthVault
//
@property (readwrite, nonatomic, retain) NSString* name;
//
// Records this user is authorized to access
//
@property (readwrite, nonatomic, retain) HVRecordCollection* records;
@property (readonly, nonatomic) BOOL hasRecords; // true if user has authorized records
//
// The records the application is currently working with
//
@property (readwrite, nonatomic) NSInteger currentRecordIndex;
@property (readonly, nonatomic) HVRecord* currentRecord;
//
// Refresh the list of authorized records - in case there were changes made using the HealthVault Shell
//
-(HVTask *) refreshAuthorizedRecords:(HVTaskCompletion) callback;
//
// Authorize additional records for this application to work with
//
-(HVTask *) authorizeAdditionalRecords:(UIViewController *) parentController andCallback:(HVTaskCompletion) callback;


-(HVClientResult *) validate;
-(BOOL) updateWithLegacyRecords:(NSArray *) records;

@end
