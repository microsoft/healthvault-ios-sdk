# MHVGoal

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**_id** | **NSString*** | The unique identifier of a goal instance. | [optional] 
**name** | **NSString*** | The name of the goal.              For example, Daily walk goal | [optional] 
**_description** | **NSString*** | The description of the goal. | [optional] 
**startDate** | **NSDate*** | The start date of the goal in Universal Time Zone(UTC). | [optional] 
**endDate** | **NSDate*** | The end date of the goal in Universal Time Zone(UTC).               If the end date is in the future, this is the target date. | [optional] 
**goalType** | **NSString*** | Specifies the type of data related to this goal. | [optional] 
**recurrenceMetrics** | [**MHVGoalRecurrenceMetrics***](MHVGoalRecurrenceMetrics.md) | The goal recurrence metrics.              For example, A goal can be defined on a weekly interval, meaning the target is intended to be achieved every week. Walking 50000 steps in a week. | [optional] 
**range** | [**MHVGoalRange***](MHVGoalRange.md) | The primary range of achievement for the goal.               For example, the ideal weight or daily steps target. | [optional] 
**additionalRanges** | [**NSArray&lt;MHVGoalRange&gt;***](MHVGoalRange.md) | Other ranges of achievement for the goal. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


