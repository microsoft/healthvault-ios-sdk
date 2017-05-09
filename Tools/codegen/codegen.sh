
mkdir output

# grab the latest swagger documentation
curl https://hvc-dev-khvwus01.westus2.cloudapp.azure.com/swagger/docs/KHV -o KHV.json

# remove the long namespaces.
sed -i '.orig' 's/Microsoft.Health.Platform.Entities.V3.Responses.//g' ./KHV.json
sed -i '.orig' 's/Microsoft.Health.Platform.Entities.ActionPlans.//g' ./KHV.json
sed -i '.orig' 's/Microsoft.Health.Platform.Entities.V3.Goals.//g' ./KHV.json
sed -i '.orig' 's/Microsoft.Health.Platform.Entities.V3.//g' ./KHV.json

# run the generator
swagger-codegen generate -i ./KHV.json -l objc -o output -c ./swagger.config -t ./swagtemplate

# remove old models
find . -iname MHVMicrosoftHealthPlatformEntitiesV1* -exec rm {} \;
find . -iname MHVV2* -exec rm {} \;
find . -iname MHVActionPlan*V2* -exec rm {} \;

