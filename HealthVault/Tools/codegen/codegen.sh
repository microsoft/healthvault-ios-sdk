
mkdir output

# grab the latest swagger documentation
curl https://hvc-dev-khvwus01.westus2.cloudapp.azure.com/swagger/docs/KHV -o KHV.json

# run the generator
swagger-codegen generate -i ./KHV.json -l objc -o output -c ./swagger.config -t ./template --reserved-words-mappings id=identifier,description=descriptionText --import-mappings Time=MHVTime


