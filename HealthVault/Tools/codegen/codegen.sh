
rm -rf output
mkdir output

# grab the latest swagger documentation
curl https://hvc-dev-khvwus01.westus2.cloudapp.azure.com/swagger/docs/2.0-preview -o KHV.json

# run the generator
swagger-codegen generate -i ./KHV.json -l objc -o output -c ./swagger.config -t ./template --reserved-words-mappings id=identifier,description=descriptionText --import-mappings Time=MHVTime

# fix Nodatime types
sed -E '
s/NSDictionary<NSString\*, NSString\*>\*/MHVLocalDate\*/g
s/"MHVErrorResponse.h"/"MHVErrorResponse.h"\
#import "MHVLocalDate.h"/g
' output/SwaggerClient/Api/MHVTimelineApi.h > output/SwaggerClient/Api/MHVTimelineApi.h2
mv output/SwaggerClient/Api/MHVTimelineApi.h2 output/SwaggerClient/Api/MHVTimelineApi.h

sed -E '
s/NSDictionary<NSString\*, NSString\*>\*/MHVLocalDate\*/g
s/"MHVErrorResponse.h"/"MHVErrorResponse.h"\
#import "MHVLocalDate.h"/g
' output/SwaggerClient/Api/MHVTimelineApi.m > output/SwaggerClient/Api/MHVTimelineApi.m2
mv output/SwaggerClient/Api/MHVTimelineApi.m2 output/SwaggerClient/Api/MHVTimelineApi.m

sed -E '
s/NSObject\* localDateTime/MHVLocalDateTime\* localDateTime/g
s/NSObject\* adherenceDelta/MHVDateTimeDuration\* adherenceDelta/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVLocalDateTime.h"\
#import "MHVDateTimeDuration.h"/g
' output/SwaggerClient/Model/MHVTimelineSchedule.h > output/SwaggerClient/Model/MHVTimelineSchedule.h2
mv output/SwaggerClient/Model/MHVTimelineSchedule.h2 output/SwaggerClient/Model/MHVTimelineSchedule.h

sed -E '
s/NSObject\* localDateTime/MHVLocalDateTime\* localDateTime/g
s/NSObject\* adherenceDelta/MHVDateTimeDuration\* adherenceDelta/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVLocalDateTime.h"/g
' output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h > output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h2
mv output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h2 output/SwaggerClient/Model/MHVTimelineScheduleOccurrence.h

sed -E '
s/NSObject\* effective/MHVInstant\* effective/g
s/"MHVEnum.h"/"MHVEnum.h"\
#import "MHVInstant.h"/g
' output/SwaggerClient/Model/MHVTimelineSnapshot.h > output/SwaggerClient/Model/MHVTimelineSnapshot.h2
mv output/SwaggerClient/Model/MHVTimelineSnapshot.h2 output/SwaggerClient/Model/MHVTimelineSnapshot.h




