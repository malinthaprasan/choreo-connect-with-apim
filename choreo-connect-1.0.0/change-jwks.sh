dcrResponse=$(curl --location --request POST 'https://localhost:9443/client-registration/v0.17/register' \
--header 'Authorization: Basic YWRtaW46YWRtaW4=' \
--header 'Content-Type: application/json' \
-d ' { "callbackUrl":"www.google.lk", "clientName":"jwkschanger", "owner":"admin", "grantType":"client_credentials password refresh_token", "saasApp":true }' -k -s)
clientId=$(echo $dcrResponse | jq -r .clientId)
clientSecret=$(echo $dcrResponse | jq  -r .clientSecret)

token=$(curl --location --request POST 'https://localhost:9443/oauth2/token' -u $clientId:$clientSecret --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'grant_type=password' --data-urlencode 'username=admin' --data-urlencode 'password=admin' --data-urlencode 'scope=apim:api_view apim:api_create apim:api_publish apim:subscribe apim:api_delete service_catalog:service_view service_catalog:service_write apim:api_generate_key apim:admin' -k -s | jq -r .access_token)

residentKMId=$(curl --location --request GET 'https://localhost:9443/api/am/admin/v2/key-managers?organizationId=carbon.super' --header "Authorization: Bearer $token" -k -s | jq -r '.list[0].id')

#echo residentKM=$residentKMId
residentKM=$(curl --location --request GET "https://localhost:9443/api/am/admin/v2/key-managers/$residentKMId?organizationId=carbon.super" --header "Authorization: Bearer $token" -k -s | jq '.certificates.value="http://apim:9763/oauth2/jwks"')

#echo $residentKM

curl -k -s -X PUT "https://localhost:9443/api/am/admin/v2/key-managers/$residentKMId?organizationId=carbon.super" --header "Authorization: Bearer $token" --header 'Content-Type: application/json'  --data-raw "$residentKM" | jq ".certificates.value"

