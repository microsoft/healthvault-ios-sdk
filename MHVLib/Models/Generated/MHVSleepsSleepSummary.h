//
// MHVSleepsSleepSummary.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

/**
* NOTE: This class is auto generated by the swagger code generator program.
* https://github.com/swagger-api/swagger-codegen.git
* Do not edit the class manually.
*/


#import <Foundation/Foundation.h>

#import "MHVModelBase.h"


@protocol MHVSleepsSleepSummary
@end

NS_ASSUME_NONNULL_BEGIN

@interface MHVSleepsSleepSummary : MHVModelBase

/* The ISO 8601 formatted time the user went to bed [optional]
 */
@property(strong,nonatomic,nullable) NSString* bedtime;
/* The ISO 8601 formatted time the user took to fall asleep [optional]
 */
@property(strong,nonatomic,nullable) NSString* fallAsleepDuration;
/* The ISO 8601 formatted time the user woke up [optional]
 */
@property(strong,nonatomic,nullable) NSString* wakeupTime;
/* The ISO 8601 formatted time the user was asleep during the activity [optional]
 */
@property(strong,nonatomic,nullable) NSString* sleepDuration;

@end

NS_ASSUME_NONNULL_END