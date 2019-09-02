echo "\nRunning Kong Auto Configuration Script - Please pay attemption at outputs for valuabe information"

#Environment Var (Such as ServerAddress and sheeet)
KONG_HOST="http://localhost"
KONG_PORT="8001"
KONG_ADDRESS="$KONG_HOST:$KONG_PORT"

KEY_AUTH='key-auth'
TCP_LOG='tcp-log'

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

resource_Create(){
    RESOURCE_TYPE=$1
    RESOURCE_NAME=$2
    RESOURCE_URL=$3

    echo "Registering Resource ${RESOURCE_NAME} :  ${RESOURCE_TYPE}"
    curl -i -X POST --url "$KONG_ADDRESS/${RESOURCE_TYPE}s" --data "name=${RESOURCE_NAME}" --data "url=${RESOURCE_URL}"
}

resource_ConfigurePaths(){
    RESOURCE_TYPE=$1
    RESOURCE_NAME=$2

    RESOURCE_METHODS=$3
    RESOURCE_PATHS=$4

    echo "Configuring ${RESOURCE_NAME} :  ${RESOURCE_TYPE}, adding routes: ${RESOURCE_PATHS}"
    curl -i -X POST --url "$KONG_ADDRESS/${RESOURCE_TYPE}s/${RESOURCE_NAME}/routes" --data "methods[]=${RESOURCE_METHODS}" --data "paths[]=${RESOURCE_PATHS}"
}

keyAuth_registerResource(){
    RESOURCE_TYPE=$1
    RESOURCE_NAME=$2

    URL="${KONG_ADDRESS}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "Register ${KEY_AUTH} to ${RESOURCE_NAME} : ${RESOURCE_TYPE}"
    curl -i -X POST --url "${URL}" --data "name=${KEY_AUTH}" --data 'config.hide_credentials=false'
}

keyAuth_registerConsumer(){
    KEY_AUTH_CONSUMER=$1

    echo "Configuring ${KEY_AUTH} for Client ${KEY_AUTH_CONSUMER}"
    curl -i -X POST --url "${KONG_ADDRESS}/consumers" --data "username=${KEY_AUTH_CONSUMER}"
}

keyAuth_registerKey(){
    KEY_AUTH_CONSUMER=$1
    KEY_AUTH_KEY=$2

    echo "Registering ${KEY_AUTH_CONSUMER} as Cosumer of ${KEY_AUTH}"
    curl -i -X POST --url "${KONG_ADDRESS}/consumers/${KEY_AUTH_CONSUMER}/${KEY_AUTH}" --data "key=${KEY_AUTH_KEY}"
}

#keyAuth_removeKey(){
#    KEY_AUTH_CONSUMER=$1
#    KEY_AUTH_KEY=$2
#
#    echo "Deleting Key ${}"
#    curl -X DELETE --url ${KONG_ADDRESS}/consumers/${KEY_AUTH_CONSUMER}/key-auth/{id}
#}
#keyAuth_removeKey 

tcpLOG_registerResource(){        
    RESOURCE_TYPE=$1
    RESOURCE_NAME=$2
    TCP_LOG_HOST=$3
    TCP_LOG_PORT=$4

    URL="${KONG_ADDRESS}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "Register ${TCP_LOG} For ${RESOURCE_NAME} : ${RESOURCE_TYPE} - Logging into ${TCP_LOG_HOST}:${TCP_LOG_PORT}"
    curl -i -X POST --url "${URL}" --data "name=${TCP_LOG}" --data "config.host=${TCP_LOG_HOST}" --data "config.port=${TCP_LOG_PORT}"
}

configure_AWSlambda(){
    curl -i -X POST --url "${URL}" --data "name=aws-lambda" --data-urlencode "config.aws_key=${AWS_KEY}" --data-urlencode "config.aws_secret=${AWS_SECRET}" --data "config.aws_region=${AWS_REGION}" --data "config.function_name=${LAMBDA_FUNCTION_NAME}"
}

configure_ACL(){
    curl -i -X POST --url "${URL}" --data "name=${ACL}" --data "config.whitelist=${ACL_WHITELIST_GROUP}" --data "config.hide_groups_header=${ACL_HIDE_GROUPS_HEADER}"   
}

configure_requestTransformation(){
    curl -i -X POST --url "${URL}" --data "name=${REQUEST_TRANSFORMER}"
}

configure_rateLimiting(){
    curl -i -X POST --url "${URL}" --data "name=${RATE_LIMITING}"
}

resource_Create "service" "bookmanager" "http://book-manager:5000/"
sleep 5s
resource_ConfigurePaths "service" "bookmanager" "GET" "/desafio"
sleep 5s
keyAuth_registerResource 'service' 'bookmanager'
sleep 5s
keyAuth_registerConsumer 'client'
sleep 5s
keyAuth_registerKey 'client' '' #Left intentionally blank - Kong will generate a Key
sleep 5s
tcpLOG_registerResource 'service' 'bookmanager' '127.0.0.1' '9999'
sleep 5s