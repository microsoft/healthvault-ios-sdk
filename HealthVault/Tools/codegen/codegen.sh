#!/bin/sh

rm -rf output
mkdir output

# grab the latest swagger documentation
curl https://hvc-dev-khvwus01.westus2.cloudapp.azure.com/swagger/docs/2.0-preview -o KHV.json

# run the generator
swagger-codegen generate -i ./KHV.json -l objc -o output -c ./swagger.config -t ./template --reserved-words-mappings id=identifier,description=descriptionText --import-mappings Time=MHVTime

# remove the models & apis that aren't applicable to a client SDK.
API_PATH=output/SwaggerClient/Api
MODEL_PATH=output/SwaggerClient/Model
rm $API_PATH/MHVOnboardingApi.* $API_PATH/MHVSleepsApi.*
rm $MODEL_PATH/MHVOnboarding* $MODEL_PATH/MHVSafeWaitHandle* $MODEL_PATH/MHVSleep* $MODEL_PATH/MHVAudit* $MODEL_PATH/MHVCancellationToken.* $MODEL_PATH/MHVWaitHandle.*

# fix Nodatime types
sed -E '
s/NSString\* )startDate/MHVLocalDate\* _Nonnull)startDate/g
s/NSString\* _Nullable)endDate/MHVLocalDate\* _Nullable)endDate/g
s/"MHVErrorResponse.h"/"MHVErrorResponse.h"\
#import "MHVLocalDate.h"/g
' output/SwaggerClient/Api/MHVTimelineApi.h > output/SwaggerClient/Api/MHVTimelineApi.h2
mv output/SwaggerClient/Api/MHVTimelineApi.h2 output/SwaggerClient/Api/MHVTimelineApi.h

sed -E '
s/NSString\* _Nonnull)startDate/MHVLocalDate\* _Nonnull)startDate/g
s/NSString\* _Nullable)endDate/MHVLocalDate\* _Nullable)endDate/g
s/"MHVErrorResponse.h"/"MHVErrorResponse.h"\
#import "MHVLocalDate.h"/g
' output/SwaggerClient/Api/MHVTimelineApi.m > output/SwaggerClient/Api/MHVTimelineApi.m2
mv output/SwaggerClient/Api/MHVTimelineApi.m2 output/SwaggerClient/Api/MHVTimelineApi.m

sed -E '
s/NSString\* localDateTime/MHVLocalDateTime\* localDateTime/g
s/NSObject\* adherenceDelta/MHVDateTimeDuration\* adherenceDelta/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVLocalDateTime.h"\
#import "MHVDateTimeDuration.h"/g
' output/SwaggerClient/Model/MHVTimelineSchedule.h > output/SwaggerClient/Model/MHVTimelineSchedule.h2
mv output/SwaggerClient/Model/MHVTimelineSchedule.h2 output/SwaggerClient/Model/MHVTimelineSchedule.h

sed -E '
s/NSString\* localDateTime/MHVLocalDateTime\* localDateTime/g
s/NSObject\* adherenceDelta/MHVDateTimeDuration\* adherenceDelta/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVLocalDateTime.h"/g
' output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h > output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h2
mv output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h2 output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h

sed -E '
s/NSString\* effective/MHVInstant\* effective/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVInstant.h"/g
' output/SwaggerClient/Model/MHVTimelineSnapshot.h > output/SwaggerClient/Model/MHVTimelineSnapshot.h2
mv output/SwaggerClient/Model/MHVTimelineSnapshot.h2 output/SwaggerClient/Model/MHVTimelineSnapshot.h

sed -E '
s/NSObject\* trackingDateTime/MHVZonedDateTime\* trackingDateTime/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVZonedDateTime.h"/g
' output/SwaggerClient/Model/MHVTaskTrackingOccurrence.h > output/SwaggerClient/Model/MHVTaskTrackingOccurrence.h2
mv output/SwaggerClient/Model/MHVTaskTrackingOccurrence.h2 output/SwaggerClient/Model/MHVTaskTrackingOccurrence.h

sed -E '
s/NSString\* _Nullable)actionPlanTaskStatus/MHVActionPlanTaskInstanceStatusEnum* _Nullable)actionPlanTaskStatus/g
' output/SwaggerClient/Api/MHVActionPlanTasksApi.h > output/SwaggerClient/Api/MHVActionPlanTasksApi.h2
mv output/SwaggerClient/Api/MHVActionPlanTasksApi.h2 output/SwaggerClient/Api/MHVActionPlanTasksApi.h

sed -E '
s/NSString\* _Nullable)actionPlanTaskStatus/MHVActionPlanTaskInstanceStatusEnum* _Nullable)actionPlanTaskStatus/g
' output/SwaggerClient/Api/MHVActionPlanTasksApi.m > output/SwaggerClient/Api/MHVActionPlanTasksApi.m2
mv output/SwaggerClient/Api/MHVActionPlanTasksApi.m2 output/SwaggerClient/Api/MHVActionPlanTasksApi.m
