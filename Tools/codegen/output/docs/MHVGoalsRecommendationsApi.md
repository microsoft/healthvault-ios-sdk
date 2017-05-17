# MHVGoalsRecommendationsApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acknowledgeGoalRecommendation**](MHVGoalsRecommendationsApi.md#acknowledgegoalrecommendation) | **PUT** /GoalRecommendations/{goalRecommendationId}/Acknowledge | Updates the goal recommendation to acknowledged state
[**addGoalRecommendation**](MHVGoalsRecommendationsApi.md#addgoalrecommendation) | **POST** /GoalRecommendations | Post a goal recommendation instance
[**deleteGoalRecommendation**](MHVGoalsRecommendationsApi.md#deletegoalrecommendation) | **DELETE** /GoalRecommendations/{goalRecommendationId} | Delete a goal recommendation instance
[**getGoalRecommendationById**](MHVGoalsRecommendationsApi.md#getgoalrecommendationbyid) | **GET** /GoalRecommendations/{goalRecommendationId} | Get an instance of a specific goal recommendation
[**getGoalRecommendations**](MHVGoalsRecommendationsApi.md#getgoalrecommendations) | **GET** /GoalRecommendations | Get a collection of all goal recommendations


# **acknowledgeGoalRecommendation**
```objc
-(NSURLSessionTask*) acknowledgeGoalRecommendationWithGoalRecommendationId: (NSString*) goalRecommendationId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Updates the goal recommendation to acknowledged state

### Example 
```objc

NSString* goalRecommendationId = @"goalRecommendationId_example"; // The identifier of the goal recommendation to acknowledge.

MHVGoalsRecommendationsApi*apiInstance = [[MHVGoalsRecommendationsApi alloc] init];

// Updates the goal recommendation to acknowledged state
[apiInstance acknowledgeGoalRecommendationWithGoalRecommendationId:goalRecommendationId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsRecommendationsApi->acknowledgeGoalRecommendation: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalRecommendationId** | **NSString***| The identifier of the goal recommendation to acknowledge. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addGoalRecommendation**
```objc
-(NSURLSessionTask*) addGoalRecommendationWithGoalRecommendation: (MHVGoalRecommendation*) goalRecommendation
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Post a goal recommendation instance

### Example 
```objc

MHVGoalRecommendation* goalRecommendation = [[MHVGoalRecommendation alloc] init]; // The instance of the goal recommendation to create.

MHVGoalsRecommendationsApi*apiInstance = [[MHVGoalsRecommendationsApi alloc] init];

// Post a goal recommendation instance
[apiInstance addGoalRecommendationWithGoalRecommendation:goalRecommendation
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsRecommendationsApi->addGoalRecommendation: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalRecommendation** | [**MHVGoalRecommendation***](MHVGoalRecommendation*.md)| The instance of the goal recommendation to create. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGoalRecommendation**
```objc
-(NSURLSessionTask*) deleteGoalRecommendationWithGoalRecommendationId: (NSString*) goalRecommendationId
        completionHandler: (void (^)(MHVSystemObject* output, NSError* error)) handler;
```

Delete a goal recommendation instance

### Example 
```objc

NSString* goalRecommendationId = @"goalRecommendationId_example"; // The identifier of the goal recommendation to delete.

MHVGoalsRecommendationsApi*apiInstance = [[MHVGoalsRecommendationsApi alloc] init];

// Delete a goal recommendation instance
[apiInstance deleteGoalRecommendationWithGoalRecommendationId:goalRecommendationId
          completionHandler: ^(MHVSystemObject* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsRecommendationsApi->deleteGoalRecommendation: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalRecommendationId** | **NSString***| The identifier of the goal recommendation to delete. | 

### Return type

[**MHVSystemObject***](MHVSystemObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGoalRecommendationById**
```objc
-(NSURLSessionTask*) getGoalRecommendationByIdWithGoalRecommendationId: (NSString*) goalRecommendationId
        completionHandler: (void (^)(MHVGoalRecommendationInstance* output, NSError* error)) handler;
```

Get an instance of a specific goal recommendation

### Example 
```objc

NSString* goalRecommendationId = @"goalRecommendationId_example"; // The goal recommendation identifier.

MHVGoalsRecommendationsApi*apiInstance = [[MHVGoalsRecommendationsApi alloc] init];

// Get an instance of a specific goal recommendation
[apiInstance getGoalRecommendationByIdWithGoalRecommendationId:goalRecommendationId
          completionHandler: ^(MHVGoalRecommendationInstance* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsRecommendationsApi->getGoalRecommendationById: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalRecommendationId** | **NSString***| The goal recommendation identifier. | 

### Return type

[**MHVGoalRecommendationInstance***](MHVGoalRecommendationInstance.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGoalRecommendations**
```objc
-(NSURLSessionTask*) getGoalRecommendationsWithGoalTypes: (NSString*) goalTypes
    goalWindowTypes: (NSString*) goalWindowTypes
        completionHandler: (void (^)(MHVGoalRecommendationsResponse* output, NSError* error)) handler;
```

Get a collection of all goal recommendations

### Example 
```objc

NSString* goalTypes = @"goalTypes_example"; // The goal types(e.g Steps, CaloriesBurned) filter. (optional)
NSString* goalWindowTypes = @"goalWindowTypes_example"; // The goal window types(e.g Daily, Weekly) filter. (optional)

MHVGoalsRecommendationsApi*apiInstance = [[MHVGoalsRecommendationsApi alloc] init];

// Get a collection of all goal recommendations
[apiInstance getGoalRecommendationsWithGoalTypes:goalTypes
              goalWindowTypes:goalWindowTypes
          completionHandler: ^(MHVGoalRecommendationsResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVGoalsRecommendationsApi->getGoalRecommendations: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalTypes** | **NSString***| The goal types(e.g Steps, CaloriesBurned) filter. | [optional] 
 **goalWindowTypes** | **NSString***| The goal window types(e.g Daily, Weekly) filter. | [optional] 

### Return type

[**MHVGoalRecommendationsResponse***](MHVGoalRecommendationsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

