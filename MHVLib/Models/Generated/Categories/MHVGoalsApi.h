//
// MHVGoalsApi.h
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

#import <Foundation/Foundation.h>
#import "MHVRemoteMonitoringClient.h"
#import "MHVGoal.h"
#import "MHVGoalsResponse.h"
#import "MHVGoalsWrapper.h"
#import "MHVMicrosoftKhronosCloudCommonErrorsErrorResponse.h"
#import "MHVSystemObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface MHVRemoteMonitoringClient (MHVGoalsApi)

/// Post a collection of goal instances
///
///
/// @param goalsWrapper The collection of goal instances to create.
///
///  code:200 message:"OK",
///  code:201 message:"Created",
///  code:0 message:"Error"
///
/// @return MHVSystemObject*
+ (NSURLSessionTask* _Nullable)createGoalsWithGoalsWrapper: (MHVGoalsWrapper* ) goalsWrapper
                                         completionHandler: (void (^ _Nonnull)(MHVSystemObject* _Nullable output, NSError* _Nullable error)) handler;


/// Delete a goal instance
///
///
/// @param goalId The identifier of the goal to delete.
///
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVSystemObject*
+ (NSURLSessionTask* _Nullable)deleteGoalWithGoalId: (NSString* ) goalId
                                  completionHandler: (void (^ _Nonnull)(MHVSystemObject* _Nullable output, NSError* _Nullable error)) handler;


/// Get a collection of the active goals
///
///
/// @param types The goal types(e.g Steps, CaloriesBurned) filter. (optional)
/// @param windowTypes The goal window types(e.g Daily, Weekly) filter. (optional)
///
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVGoalsResponse*
+ (NSURLSessionTask* _Nullable)getActiveGoalsWithTypes: (NSString* _Nullable) types
                                           windowTypes: (NSString* _Nullable) windowTypes
                                     completionHandler: (void (^ _Nonnull)(MHVGoalsResponse* _Nullable output, NSError* _Nullable error)) handler;


/// Get an instance of a specific goal
///
///
/// @param goalId The goal identifier.
///
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVGoal*
+ (NSURLSessionTask* _Nullable)getGoalByIdWithGoalId: (NSString* ) goalId
                                   completionHandler: (void (^ _Nonnull)(MHVGoal* _Nullable output, NSError* _Nullable error)) handler;


/// Get a collection of all goals
///
///
/// @param types The goal types(e.g Steps, CaloriesBurned) filter. (optional)
/// @param windowTypes The goal window types(e.g Daily, Weekly) filter. (optional)
/// @param startDate The start date for date range filter. (optional)
/// @param endDate The end date for date range filter. (optional)
///
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVGoalsResponse*
+ (NSURLSessionTask* _Nullable)getGoalsWithTypes: (NSString* _Nullable) types
                                     windowTypes: (NSString* _Nullable) windowTypes
                                       startDate: (NSDate* _Nullable) startDate
                                         endDate: (NSDate* _Nullable) endDate
                               completionHandler: (void (^ _Nonnull)(MHVGoalsResponse* _Nullable output, NSError* _Nullable error)) handler;


/// Update collection of goal instances with merge
///
///
/// @param goalsWrapper The collection of goal instances to update. Only the fields present in the passed in model will be updated. All other fields and colelctions              will be left, as is, unless invalid.
///
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVGoalsResponse*
+ (NSURLSessionTask* _Nullable)patchGoalsWithGoalsWrapper: (MHVGoalsWrapper* ) goalsWrapper
                                        completionHandler: (void (^ _Nonnull)(MHVGoalsResponse* _Nullable output, NSError* _Nullable error)) handler;


/// Update/Replace a complete goal instance with no merge
///
///
/// @param goal The instance of the goal to update. The entire goal will be replaced with this version.
/// 
///  code:200 message:"OK",
///  code:0 message:"Error"
///
/// @return MHVGoal*
+ (NSURLSessionTask* _Nullable)putGoalWithGoal: (MHVGoal* ) goal
                             completionHandler: (void (^ _Nonnull)(MHVGoal* _Nullable output, NSError* _Nullable error)) handler;



@end

NS_ASSUME_NONNULL_END
