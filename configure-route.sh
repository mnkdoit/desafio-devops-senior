echo "\nRunning Kong Auto Configuration Script - Please pay attemption at outputs for valuabe information"

#Environment Var (Such as ServerAddress and sheeet)
HOST=http://localhost
PORT=8001
ADDRESS="$HOST:$PORT"

#Resource
RESOURCE="bookmanager"
RESOURCE_TYPE="service"
RESOURCE_ADDRESS="http://book-manager:5000/"

#Plugins Variables
#Key-Auth
KEY_AUTH='key-auth'
KEY_AUTH_CLIENT='client'
KEY_AUTH_KEY='20644b66-36a8-4c46-9460-5a87247a3e3d'

#TCP-LOG
TCP_LOG='tcp-log'
TCP_LOG_HOST='127.0.0.1'
TCP_LOG_PORT='9999'

#AWS-Lambda
AWS_LAMBDA='aws-lambda'
AWS_KEY='SUA CHAVE DE ACESSO DA AWS'
AWS_SECRET='SECRET DA AWS'
AWS_REGION='us-west-1'
LAMBDA_FUNCTION_NAME='LAMBDA'

#ACL
ACL='acl'
ACL_WHITELIST_GROUP='group1'
ACL_HIDE_GROUPS_HEADER='true'

#Request-Transformation
REQUEST_TRANSFORMER='request-transformer-advanced'

#Rate-Limiting
RATE_LIMITING='rate-limiting-advanced'

#Resource Creation
echo "\nRegistering Resource: ${RESOURCE}"
curl -i -X POST --url $ADDRESS/${RESOURCE_TYPE}s/ --data "name=${RESOURCE}" --data "url=${RESOURCE_ADDRESS}"
curl -i -X POST --url $ADDRESS/${RESOURCE_TYPE}s/${RESOURCE}/routes/ --data 'methods[]=GET' --data 'paths[]=/desafio'

####################################
echo "\nConfiguring Plugins for ${RESOURCE}"

URL="${ADDRESS}/${RESOURCE_TYPE}s/${RESOURCE}/plugins/"

#Key Auth
echo "\nRegister ${KEY_AUTH}"
curl -i -X POST --url ${URL} \
--data "name=${KEY_AUTH}" \
--data 'config.hide_credentials=false'

#TCP-LOG
echo "\nRegister ${TCP_LOG}"
curl -i -X POST --url ${URL} \
--data "name=${TCP_LOG}" \
--data "config.host=${TCP_LOG_HOST}" \
--data "config.port=${TCP_LOG_PORT}"

#AWS-Lambda
curl -i -X POST --url ${URL}
--data "name=aws-lambda" \
--data-urlencode "config.aws_key=${AWS_KEY}" \
--data-urlencode "config.aws_secret=${AWS_SECRET}" \
--data "config.aws_region=${AWS_REGION}" \
--data "config.function_name=${LAMBDA_FUNCTION_NAME}"

#ACL
curl -i -X POST --url ${URL} \
--data "name=${ACL}"  \
--data "config.whitelist=${ACL_WHITELIST_GROUP}" \
--data "config.hide_groups_header=${ACL_HIDE_GROUPS_HEADER}"

#Request-Transformation
curl -i -X POST --url ${URL} \
--data "name=${REQUEST_TRANSFORMER}"

#Rate-Limiting
curl -i -X POST --url ${URL} \
--data "name=${RATE_LIMITING}"

#KEY-AUTH Client Config
echo "\nConfiguring Key-Auth Client"
curl -i -X POST --url ${ADDRESS}/consumers/ --data "username=${KEY_AUTH_CLIENT}"
curl -i -X POST --url ${ADDRESS}/consumers/${KEY_AUTH_CLIENT}/key-auth/ --data "key=${KEY_AUTH_KEY}"