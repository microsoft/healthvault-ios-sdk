# MHVActionPlansApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createActionPlan**](MHVActionPlansApi.md#createactionplan) | **POST** /ActionPlans | Post an action plan instance
[**deleteActionPlan**](MHVActionPlansApi.md#deleteactionplan) | **DELETE** /ActionPlans/{actionPlanId} | Delete an action plan instance
[**deleteActionPlanObjective**](MHVActionPlansApi.md#deleteactionplanobjective) | **DELETE** /ActionPlans/{actionPlanId}/Objectives/{objectiveId} | Remove an action plan objective
[**getActionPlanAdherence**](MHVActionPlansApi.md#getactionplanadherence) | **GET** /ActionPlans/{actionPlanId}/Adherence | Gets adherence information for an action plan.
[**getActionPlanById**](MHVActionPlansApi.md#getactionplanbyid) | **GET** /ActionPlans/{actionPlanId} | Get an instance of a specific action plan
[**getActionPlans**](MHVActionPlansApi.md#getactionplans) | **GET** /ActionPlans | Get a collection of action plans
[**patchActionPlan**](MHVActionPlansApi.md#patchactionplan) | **PATCH** /ActionPlans | Update an action plan instance with merge
[**putActionPlan**](MHVActionPlansApi.md#putactionplan) | **PUT** /ActionPlans | Update/Replace a complete action plan instance with no merge.


# **createActionPlan**
```objc
-(NSURLSessionTask*) createActionPlanWithActionPlan: (MHVV2ActionPlan*) actionPlan
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Post an action plan instance

### Example 
```objc

MHVV2ActionPlan* actionPlan = [[MHVV2ActionPlan alloc] init]; // The instance of the plan to create.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Post an action plan instance
[apiInstance createActionPlanWithActionPlan:actionPlan
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->createActionPlan: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlan** | [**MHVV2ActionPlan***](MHVV2ActionPlan*.md)| The instance of the plan to create. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteActionPlan**
```objc
-(NSURLSessionTask*) deleteActionPlanWithActionPlanId: (NSString*) actionPlanId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Delete an action plan instance

### Example 
```objc

NSString* actionPlanId = @"actionPlanId_example"; // The instance of the plan to delete.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Delete an action plan instance
[apiInstance deleteActionPlanWithActionPlanId:actionPlanId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->deleteActionPlan: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanId** | **NSString***| The instance of the plan to delete. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteActionPlanObjective**
```objc
-(NSURLSessionTask*) deleteActionPlanObjectiveWithActionPlanId: (NSString*) actionPlanId
    objectiveId: (NSString*) objectiveId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Remove an action plan objective

### Example 
```objc

NSString* actionPlanId = @"actionPlanId_example"; // The instance of the plan that the objective belongs to.
NSString* objectiveId = @"objectiveId_example"; // The instance of the objective to delete.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Remove an action plan objective
[apiInstance deleteActionPlanObjectiveWithActionPlanId:actionPlanId
              objectiveId:objectiveId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->deleteActionPlanObjective: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanId** | **NSString***| The instance of the plan that the objective belongs to. | 
 **objectiveId** | **NSString***| The instance of the objective to delete. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActionPlanAdherence**
```objc
-(NSURLSessionTask*) getActionPlanAdherenceWithStartTime: (NSDate*) startTime
    endTime: (NSDate*) endTime
    actionPlanId: (NSString*) actionPlanId
    objectiveId: (NSString*) objectiveId
    taskId: (NSString*) taskId
        completionHandler: (void (^)(MHVActionPlanAdherenceSummary* output, NSError* error)) handler;
```

Gets adherence information for an action plan.

### Example 
```objc

NSDate* startTime = @"2013-10-20T19:20:30+01:00"; // The start time.
NSDate* endTime = @"2013-10-20T19:20:30+01:00"; // The end time.
NSString* actionPlanId = @"actionPlanId_example"; // The action plan identifier.
NSString* objectiveId = @"objectiveId_example"; // The objective to filter the report to. (optional)
NSString* taskId = @"taskId_example"; // The task to filter the report to. (optional)

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Gets adherence information for an action plan.
[apiInstance getActionPlanAdherenceWithStartTime:startTime
              endTime:endTime
              actionPlanId:actionPlanId
              objectiveId:objectiveId
              taskId:taskId
          completionHandler: ^(MHVActionPlanAdherenceSummary* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->getActionPlanAdherence: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startTime** | **NSDate***| The start time. | 
 **endTime** | **NSDate***| The end time. | 
 **actionPlanId** | **NSString***| The action plan identifier. | 
 **objectiveId** | **NSString***| The objective to filter the report to. | [optional] 
 **taskId** | **NSString***| The task to filter the report to. | [optional] 

### Return type

[**MHVActionPlanAdherenceSummary***](MHVActionPlanAdherenceSummary.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActionPlanById**
```objc
-(NSURLSessionTask*) getActionPlanByIdWithActionPlanId: (NSString*) actionPlanId
        completionHandler: (void (^)(MHVV2ActionPlanInstance* output, NSError* error)) handler;
```

Get an instance of a specific action plan

### Example 
```objc

NSString* actionPlanId = @"actionPlanId_example"; // The action plan to update.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Get an instance of a specific action plan
[apiInstance getActionPlanByIdWithActionPlanId:actionPlanId
          completionHandler: ^(MHVV2ActionPlanInstance* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->getActionPlanById: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanId** | **NSString***| The action plan to update. | 

### Return type

[**MHVV2ActionPlanInstance***](MHVV2ActionPlanInstance.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActionPlans**
```objc
-(NSURLSessionTask*) getActionPlansWithMaxPageSize: (NSNumber*) maxPageSize
        completionHandler: (void (^)(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error)) handler;
```

Get a collection of action plans

### Example 
```objc

NSNumber* maxPageSize = @56; // The maximum number of entries to return per page. Defaults to 1000. (optional)

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Get a collection of action plans
[apiInstance getActionPlansWithMaxPageSize:maxPageSize
          completionHandler: ^(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->getActionPlans: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **maxPageSize** | **NSNumber***| The maximum number of entries to return per page. Defaults to 1000. | [optional] 

### Return type

[**MHVActionPlansResponseV2ActionPlanInstance_***](MHVActionPlansResponseV2ActionPlanInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchActionPlan**
```objc
-(NSURLSessionTask*) patchActionPlanWithActionPlan: (MHVV2ActionPlanInstance*) actionPlan
        completionHandler: (void (^)(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error)) handler;
```

Update an action plan instance with merge

### Example 
```objc

MHVV2ActionPlanInstance* actionPlan = [[MHVV2ActionPlanInstance alloc] init]; // The instance of the plan to update. Only the fields present in the passed in model will be updated. All other fields and colelctions              will be left, as is, unless invalid.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Update an action plan instance with merge
[apiInstance patchActionPlanWithActionPlan:actionPlan
          completionHandler: ^(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->patchActionPlan: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlan** | [**MHVV2ActionPlanInstance***](MHVV2ActionPlanInstance*.md)| The instance of the plan to update. Only the fields present in the passed in model will be updated. All other fields and colelctions              will be left, as is, unless invalid. | 

### Return type

[**MHVActionPlansResponseV2ActionPlanInstance_***](MHVActionPlansResponseV2ActionPlanInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putActionPlan**
```objc
-(NSURLSessionTask*) putActionPlanWithActionPlan: (MHVV2ActionPlanInstance*) actionPlan
        completionHandler: (void (^)(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error)) handler;
```

Update/Replace a complete action plan instance with no merge.

### Example 
```objc

MHVV2ActionPlanInstance* actionPlan = [[MHVV2ActionPlanInstance alloc] init]; // The instance of the plan to update. The entire plan will be replaced with this version.

MHVActionPlansApi*apiInstance = [[MHVActionPlansApi alloc] init];

// Update/Replace a complete action plan instance with no merge.
[apiInstance putActionPlanWithActionPlan:actionPlan
          completionHandler: ^(MHVActionPlansResponseV2ActionPlanInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlansApi->putActionPlan: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlan** | [**MHVV2ActionPlanInstance***](MHVV2ActionPlanInstance*.md)| The instance of the plan to update. The entire plan will be replaced with this version. | 

### Return type

[**MHVActionPlansResponseV2ActionPlanInstance_***](MHVActionPlansResponseV2ActionPlanInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

