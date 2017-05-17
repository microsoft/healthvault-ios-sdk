# MHVOnboardingApi

All URIs are relative to *https://hvc-dev-khvwus01.westus2.cloudapp.azure.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**generateInviteCode**](MHVOnboardingApi.md#generateinvitecode) | **POST** /Onboarding/GenerateInviteCode | Onboard a user


# **generateInviteCode**
```objc
-(NSURLSessionTask*) generateInviteCodeWithOnboardingRequest: (MHVOnboardingRequest*) onboardingRequest
        completionHandler: (void (^)(MHVOnboardingResponse* output, NSError* error)) handler;
```

Onboard a user

### Example 
```objc

MHVOnboardingRequest* onboardingRequest = [[MHVOnboardingRequest alloc] init]; // The meta data associated with an onboarding request

MHVOnboardingApi*apiInstance = [[MHVOnboardingApi alloc] init];

// Onboard a user
[apiInstance generateInviteCodeWithOnboardingRequest:onboardingRequest
          completionHandler: ^(MHVOnboardingResponse* output, NSError* error) {
                        if (output) {
                            NSLog(@"%@", output);
                        }
                        if (error) {
                            NSLog(@"Error calling MHVOnboardingApi->generateInviteCode: %@", error);
                        }
                    }];
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **onboardingRequest** | [**MHVOnboardingRequest***](MHVOnboardingRequest*.md)| The meta data associated with an onboarding request | 

### Return type

[**MHVOnboardingResponse***](MHVOnboardingResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, text/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

