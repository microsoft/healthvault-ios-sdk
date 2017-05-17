# MHVGoalsApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createGoals**](MHVGoalsApi.md#creategoals) | **POST** /Goals | Post a collection of goal instances
[**deleteGoal**](MHVGoalsApi.md#deletegoal) | **DELETE** /Goals/{goalId} | Delete a goal instance
[**getActiveGoals**](MHVGoalsApi.md#getactivegoals) | **GET** /Goals/active | Get a collection of the active goals
[**getGoalById**](MHVGoalsApi.md#getgoalbyid) | **GET** /Goals/{goalId} | Get an instance of a specific goal
[**getGoals**](MHVGoalsApi.md#getgoals) | **GET** /Goals | Get a collection of all goals
[**patchGoals**](MHVGoalsApi.md#patchgoals) | **PATCH** /Goals | Update collection of goal instances with merge
[**putGoal**](MHVGoalsApi.md#putgoal) | **PUT** /Goals | Update/Replace a complete goal instance with no merge


# **createGoals**
```objc
-(NSURLSessionTask*) createGoalsWithGoalsWrapper: (MHVGoalsWrapper*) goalsWrapper
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Post a collection of goal instances

### Example 
```objc

MHVGoalsWrapper* goalsWrapper = [[MHVGoalsWrapper alloc] init]; // The collection of goal instances to create.

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Post a collection of goal instances
[apiInstance createGoalsWithGoalsWrapper:goalsWrapper
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->createGoals: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalsWrapper** | [**MHVGoalsWrapper***](MHVGoalsWrapper*.md)| The collection of goal instances to create. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGoal**
```objc
-(NSURLSessionTask*) deleteGoalWithGoalId: (NSString*) goalId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Delete a goal instance

### Example 
```objc

NSString* goalId = @"goalId_example"; // The identifier of the goal to delete.

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Delete a goal instance
[apiInstance deleteGoalWithGoalId:goalId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->deleteGoal: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **NSString***| The identifier of the goal to delete. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActiveGoals**
```objc
-(NSURLSessionTask*) getActiveGoalsWithTypes: (NSString*) types
    windowTypes: (NSString*) windowTypes
        completionHandler: (void (^)(MHVGoalsResponse* output, NSError* error)) handler;
```

Get a collection of the active goals

### Example 
```objc

NSString* types = @"types_example"; // The goal types(e.g Steps, CaloriesBurned) filter. (optional)
NSString* windowTypes = @"windowTypes_example"; // The goal window types(e.g Daily, Weekly) filter. (optional)

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Get a collection of the active goals
[apiInstance getActiveGoalsWithTypes:types
              windowTypes:windowTypes
          completionHandler: ^(MHVGoalsResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->getActiveGoals: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **types** | **NSString***| The goal types(e.g Steps, CaloriesBurned) filter. | [optional] 
 **windowTypes** | **NSString***| The goal window types(e.g Daily, Weekly) filter. | [optional] 

### Return type

[**MHVGoalsResponse***](MHVGoalsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGoalById**
```objc
-(NSURLSessionTask*) getGoalByIdWithGoalId: (NSString*) goalId
        completionHandler: (void (^)(MHVGoal* output, NSError* error)) handler;
```

Get an instance of a specific goal

### Example 
```objc

NSString* goalId = @"goalId_example"; // The goal identifier.

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Get an instance of a specific goal
[apiInstance getGoalByIdWithGoalId:goalId
          completionHandler: ^(MHVGoal* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->getGoalById: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **NSString***| The goal identifier. | 

### Return type

[**MHVGoal***](MHVGoal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGoals**
```objc
-(NSURLSessionTask*) getGoalsWithTypes: (NSString*) types
    windowTypes: (NSString*) windowTypes
    startDate: (NSDate*) startDate
    endDate: (NSDate*) endDate
        completionHandler: (void (^)(MHVGoalsResponse* output, NSError* error)) handler;
```

Get a collection of all goals

### Example 
```objc

NSString* types = @"types_example"; // The goal types(e.g Steps, CaloriesBurned) filter. (optional)
NSString* windowTypes = @"windowTypes_example"; // The goal window types(e.g Daily, Weekly) filter. (optional)
NSDate* startDate = @"2013-10-20T19:20:30+01:00"; // The start date for date range filter. (optional)
NSDate* endDate = @"2013-10-20T19:20:30+01:00"; // The end date for date range filter. (optional)

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Get a collection of all goals
[apiInstance getGoalsWithTypes:types
              windowTypes:windowTypes
              startDate:startDate
              endDate:endDate
          completionHandler: ^(MHVGoalsResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->getGoals: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **types** | **NSString***| The goal types(e.g Steps, CaloriesBurned) filter. | [optional] 
 **windowTypes** | **NSString***| The goal window types(e.g Daily, Weekly) filter. | [optional] 
 **startDate** | **NSDate***| The start date for date range filter. | [optional] 
 **endDate** | **NSDate***| The end date for date range filter. | [optional] 

### Return type

[**MHVGoalsResponse***](MHVGoalsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchGoals**
```objc
-(NSURLSessionTask*) patchGoalsWithGoalsWrapper: (MHVGoalsWrapper*) goalsWrapper
        completionHandler: (void (^)(MHVGoalsResponse* output, NSError* error)) handler;
```

Update collection of goal instances with merge

### Example 
```objc

MHVGoalsWrapper* goalsWrapper = [[MHVGoalsWrapper alloc] init]; // The collection of goal instances to update. Only the fields present in the passed in model will be updated. All other fields and colelctions              will be left, as is, unless invalid.

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Update collection of goal instances with merge
[apiInstance patchGoalsWithGoalsWrapper:goalsWrapper
          completionHandler: ^(MHVGoalsResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->patchGoals: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalsWrapper** | [**MHVGoalsWrapper***](MHVGoalsWrapper*.md)| The collection of goal instances to update. Only the fields present in the passed in model will be updated. All other fields and colelctions              will be left, as is, unless invalid. | 

### Return type

[**MHVGoalsResponse***](MHVGoalsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putGoal**
```objc
-(NSURLSessionTask*) putGoalWithGoal: (MHVGoal*) goal
        completionHandler: (void (^)(MHVGoal* output, NSError* error)) handler;
```

Update/Replace a complete goal instance with no merge

### Example 
```objc

MHVGoal* goal = [[MHVGoal alloc] init]; // The instance of the goal to update. The entire goal will be replaced with this version.

MHVGoalsApi*apiInstance = [[MHVGoalsApi alloc] init];

// Update/Replace a complete goal instance with no merge
[apiInstance putGoalWithGoal:goal
          completionHandler: ^(MHVGoal* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsApi->putGoal: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goal** | [**MHVGoal***](MHVGoal*.md)| The instance of the goal to update. The entire goal will be replaced with this version. | 

### Return type

[**MHVGoal***](MHVGoal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

