# MHVActionPlanInstance

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**_id** | **NSString*** | The ID of the plan instance | [optional] 
**status** | **NSString*** | The status of the plan | [optional] 
**organizationId** | **NSString*** | The ID of the organization that manages this plan. Read-only | [optional] 
**organizationName** | **NSString*** | The name of the organization that manages this plan. Read-only | [optional] 
**associatedTasks** | [**NSArray&lt;MHVActionPlanTaskInstance&gt;***](MHVActionPlanTaskInstance.md) | The Task instances associated with this plan | [optional] 
**name** | **NSString*** | The name of the plan, localized | [optional] 
**_description** | **NSString*** | The description of the plan, localized | [optional] 
**imageUrl** | **NSString*** | An HTTPS URL to an image for the plan. Suggested resolution is 212x212 with a 25px margin in the image. | [optional] 
**thumbnailImageUrl** | **NSString*** | An HTTPS URL to a thumbnail image for the plan. Suggested resolution is 212x212 with a 25px margin in the image. | [optional] 
**category** | **NSString*** | The category of the plan | [optional] 
**objectives** | [**NSArray&lt;MHVObjective&gt;***](MHVObjective.md) | The Collection of objectives for the plan | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


