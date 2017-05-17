# MHVSleepsApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSleeps**](MHVSleepsApi.md#getsleeps) | **GET** /Sleeps | Get the Sleep Activity data for this user by date range


# **getSleeps**
```objc
-(NSURLSessionTask*) getSleepsWithStartTime: (NSDate*) startTime
    endTime: (NSDate*) endTime
    includeDetails: (NSString*) includeDetails
    maxPageSize: (NSNumber*) maxPageSize
        completionHandler: (void (^)(MHVSleepResponse* output, NSError* error)) handler;
```

Get the Sleep Activity data for this user by date range

### Example 
```objc

NSDate* startTime = @"2013-10-20T19:20:30+01:00"; // The ISO 8601 formatted start time of the Sleep activities, inclusive. (optional)
NSDate* endTime = @"2013-10-20T19:20:30+01:00"; // The ISO 8601 formatted end time of the Sleep activities, exclusive.  Defaults to the current time in UTC. (optional)
NSString* includeDetails = @"includeDetails_example"; // comma separated string to additional details. Available values Basic, Full. Default - Basic (optional)
NSNumber* maxPageSize = @56; // The maximum number of entries to return per page.  Defaults to 31 (optional)

MHVSleepsApi*apiInstance = [[MHVSleepsApi alloc] init];

// Get the Sleep Activity data for this user by date range
[apiInstance getSleepsWithStartTime:startTime
              endTime:endTime
              includeDetails:includeDetails
              maxPageSize:maxPageSize
          completionHandler: ^(MHVSleepResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVSleepsApi->getSleeps: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startTime** | **NSDate***| The ISO 8601 formatted start time of the Sleep activities, inclusive. | [optional] 
 **endTime** | **NSDate***| The ISO 8601 formatted end time of the Sleep activities, exclusive.  Defaults to the current time in UTC. | [optional] 
 **includeDetails** | **NSString***| comma separated string to additional details. Available values Basic, Full. Default - Basic | [optional] 
 **maxPageSize** | **NSNumber***| The maximum number of entries to return per page.  Defaults to 31 | [optional] 

### Return type

[**MHVSleepResponse***](MHVSleepResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

