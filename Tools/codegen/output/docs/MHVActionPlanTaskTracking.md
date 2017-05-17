# MHVActionPlanTaskTracking

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**_id** | **NSString*** | Gets or sets the Id of the task tracking | [optional] 
**trackingType** | **NSString*** | Gets or sets the task tracking type | [optional] 
**timeZoneOffset** | **NSNumber*** | Gets or sets the timezone offset of the task tracking,               if a task is local time based, it should be set as null | [optional] 
**trackingDateTime** | **NSDate*** | Gets or sets the task tracking time | [optional] 
**creationDateTime** | **NSDate*** | Gets or sets the creation time of the task tracking | [optional] 
**trackingStatus** | **NSString*** | Gets or sets the task tracking status | [optional] 
**occurrenceStart** | **NSDate*** | Gets or sets the start time of the occurrence window,              it is null for Completion and OutOfWindow tracking | [optional] 
**occurrenceEnd** | **NSDate*** | Gets or sets the end time of the occurrence window,              it is null for Completion and OutOfWindow tracking | [optional] 
**completionStart** | **NSDate*** | Gets or sets the start time of the completion window | [optional] 
**completionEnd** | **NSDate*** | Gets or sets the end time of the completion window | [optional] 
**taskId** | **NSString*** | Gets or sets task Id | [optional] 
**feedback** | **NSString*** | Gets or sets the tracking feedback | [optional] 
**evidence** | [**MHVActionPlanTaskTrackingEvidence***](MHVActionPlanTaskTrackingEvidence.md) | Gets or sets the evidence of the task tracking | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


