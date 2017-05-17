# MHVActionPlanTasksApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteActionPlanTasksById**](MHVActionPlanTasksApi.md#deleteactionplantasksbyid) | **DELETE** /ActionPlanTasks/{actionPlanTaskId} | Delete a task by id
[**getActionPlanTaskById**](MHVActionPlanTasksApi.md#getactionplantaskbyid) | **GET** /ActionPlanTasks/{actionPlanTaskId} | Get a task by id
[**getActionPlanTasks**](MHVActionPlanTasksApi.md#getactionplantasks) | **GET** /ActionPlanTasks | Get a collection of task definitions
[**patchActionPlanTasks**](MHVActionPlanTasksApi.md#patchactionplantasks) | **PATCH** /ActionPlanTasks | Patch an update for an action plan task
[**postActionPlanTasks**](MHVActionPlanTasksApi.md#postactionplantasks) | **POST** /ActionPlanTasks | Post a new action plan task
[**putActionPlanTasks**](MHVActionPlanTasksApi.md#putactionplantasks) | **PUT** /ActionPlanTasks | Put an update for an action plan task
[**validateActionPlanTasksTracking**](MHVActionPlanTasksApi.md#validateactionplantaskstracking) | **POST** /ActionPlanTasks/ValidateTracking | 


# **deleteActionPlanTasksById**
```objc
-(NSURLSessionTask*) deleteActionPlanTasksByIdWithActionPlanTaskId: (NSString*) actionPlanTaskId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Delete a task by id

### Example 
```objc

NSString* actionPlanTaskId = @"actionPlanTaskId_example"; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Delete a task by id
[apiInstance deleteActionPlanTasksByIdWithActionPlanTaskId:actionPlanTaskId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->deleteActionPlanTasksById: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTaskId** | **NSString***|  | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActionPlanTaskById**
```objc
-(NSURLSessionTask*) getActionPlanTaskByIdWithActionPlanTaskId: (NSString*) actionPlanTaskId
        completionHandler: (void (^)(MHVV2ActionPlanTaskInstance* output, NSError* error)) handler;
```

Get a task by id

### Example 
```objc

NSString* actionPlanTaskId = @"actionPlanTaskId_example"; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Get a task by id
[apiInstance getActionPlanTaskByIdWithActionPlanTaskId:actionPlanTaskId
          completionHandler: ^(MHVV2ActionPlanTaskInstance* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->getActionPlanTaskById: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTaskId** | **NSString***|  | 

### Return type

[**MHVV2ActionPlanTaskInstance***](MHVV2ActionPlanTaskInstance.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActionPlanTasks**
```objc
-(NSURLSessionTask*) getActionPlanTasksWithActionPlanTaskStatus: (NSString*) actionPlanTaskStatus
    maxPageSize: (NSNumber*) maxPageSize
        completionHandler: (void (^)(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error)) handler;
```

Get a collection of task definitions

### Example 
```objc

NSString* actionPlanTaskStatus = @"actionPlanTaskStatus_example"; //  (optional)
NSNumber* maxPageSize = @56; // The maximum number of entries to return per page. Defaults to 1000. (optional)

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Get a collection of task definitions
[apiInstance getActionPlanTasksWithActionPlanTaskStatus:actionPlanTaskStatus
              maxPageSize:maxPageSize
          completionHandler: ^(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->getActionPlanTasks: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTaskStatus** | **NSString***|  | [optional] 
 **maxPageSize** | **NSNumber***| The maximum number of entries to return per page. Defaults to 1000. | [optional] 

### Return type

[**MHVActionPlanTasksResponseV2ActionPlanTaskInstance_***](MHVActionPlanTasksResponseV2ActionPlanTaskInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchActionPlanTasks**
```objc
-(NSURLSessionTask*) patchActionPlanTasksWithActionPlanTask: (MHVV2ActionPlanTaskInstance*) actionPlanTask
        completionHandler: (void (^)(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error)) handler;
```

Patch an update for an action plan task

### Example 
```objc

MHVV2ActionPlanTaskInstance* actionPlanTask = [[MHVV2ActionPlanTaskInstance alloc] init]; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Patch an update for an action plan task
[apiInstance patchActionPlanTasksWithActionPlanTask:actionPlanTask
          completionHandler: ^(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->patchActionPlanTasks: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTask** | [**MHVV2ActionPlanTaskInstance***](MHVV2ActionPlanTaskInstance*.md)|  | 

### Return type

[**MHVActionPlanTasksResponseV2ActionPlanTaskInstance_***](MHVActionPlanTasksResponseV2ActionPlanTaskInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postActionPlanTasks**
```objc
-(NSURLSessionTask*) postActionPlanTasksWithActionPlanTask: (MHVV2ActionPlanTask*) actionPlanTask
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Post a new action plan task

### Example 
```objc

MHVV2ActionPlanTask* actionPlanTask = [[MHVV2ActionPlanTask alloc] init]; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Post a new action plan task
[apiInstance postActionPlanTasksWithActionPlanTask:actionPlanTask
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->postActionPlanTasks: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTask** | [**MHVV2ActionPlanTask***](MHVV2ActionPlanTask*.md)|  | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putActionPlanTasks**
```objc
-(NSURLSessionTask*) putActionPlanTasksWithActionPlanTask: (MHVV2ActionPlanTaskInstance*) actionPlanTask
        completionHandler: (void (^)(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error)) handler;
```

Put an update for an action plan task

### Example 
```objc

MHVV2ActionPlanTaskInstance* actionPlanTask = [[MHVV2ActionPlanTaskInstance alloc] init]; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

// Put an update for an action plan task
[apiInstance putActionPlanTasksWithActionPlanTask:actionPlanTask
          completionHandler: ^(MHVActionPlanTasksResponseV2ActionPlanTaskInstance_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->putActionPlanTasks: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionPlanTask** | [**MHVV2ActionPlanTaskInstance***](MHVV2ActionPlanTaskInstance*.md)|  | 

### Return type

[**MHVActionPlanTasksResponseV2ActionPlanTaskInstance_***](MHVActionPlanTasksResponseV2ActionPlanTaskInstance_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **validateActionPlanTasksTracking**
```objc
-(NSURLSessionTask*) validateActionPlanTasksTrackingWithTrackingValidation: (MHVTrackingValidation*) trackingValidation
        completionHandler: (void (^)(MHVActionPlanTaskTrackingResponseActionPlanTaskTracking_* output, NSError* error)) handler;
```



### Example 
```objc

MHVTrackingValidation* trackingValidation = [[MHVTrackingValidation alloc] init]; // 

MHVActionPlanTasksApi*apiInstance = [[MHVActionPlanTasksApi alloc] init];

[apiInstance validateActionPlanTasksTrackingWithTrackingValidation:trackingValidation
          completionHandler: ^(MHVActionPlanTaskTrackingResponseActionPlanTaskTracking_* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVActionPlanTasksApi->validateActionPlanTasksTracking: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackingValidation** | [**MHVTrackingValidation***](MHVTrackingValidation*.md)|  | 

### Return type

[**MHVActionPlanTaskTrackingResponseActionPlanTaskTracking_***](MHVActionPlanTaskTrackingResponseActionPlanTaskTracking_.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

