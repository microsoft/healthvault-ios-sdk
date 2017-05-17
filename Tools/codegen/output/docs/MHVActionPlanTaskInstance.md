# MHVActionPlanTaskInstance

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**_id** | **NSString*** | The Id of the task instance | [optional] 
**status** | **NSString*** | The status of the task | [optional] 
**startDate** | **NSDate*** | The date that the task was started. Read-only | [optional] 
**endDate** | **NSDate*** | The date that the task was ended. Read-only | [optional] 
**organizationId** | **NSString*** | The ID of the organization that owns this task. Read-only | [optional] 
**organizationName** | **NSString*** | The name of the organization that owns this task. Read-only | [optional] 
**name** | **NSString*** | The friendly name of the task | [optional] 
**shortDescription** | **NSString*** | The short description of the task | [optional] 
**longDescription** | **NSString*** | The detailed description of the task | [optional] 
**imageUrl** | **NSString*** | The image URL of the task. Suggested resolution is 200 x 200 | [optional] 
**thumbnailImageUrl** | **NSString*** | The thumbnail image URL of the task. Suggested resolution is 90 x 90 | [optional] 
**taskType** | **NSString*** | The type of the task, used to choose the UI editor for the task | [optional] 
**trackingPolicy** | [**MHVActionPlanTrackingPolicy***](MHVActionPlanTrackingPolicy.md) | The tracking policy | [optional] 
**signupName** | **NSString*** | The text shown during task signup. | [optional] 
**associatedPlanId** | **NSString*** | The ID of the associated plan. This is not needed when adding a task as part of a new plan | [optional] 
**associatedObjectiveIds** | **NSArray&lt;NSString*&gt;*** | The list of objective IDs the task is associated with | [optional] 
**completionType** | **NSString*** | The Completion Type of the Task | [optional] 
**frequencyTaskCompletionMetrics** | [**MHVActionPlanFrequencyTaskCompletionMetrics***](MHVActionPlanFrequencyTaskCompletionMetrics.md) | Completion metrics for frequency based tasks | [optional] 
**scheduledTaskCompletionMetrics** | [**MHVActionPlanScheduledTaskCompletionMetrics***](MHVActionPlanScheduledTaskCompletionMetrics.md) | Completion metrics for schedule based tasks | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


