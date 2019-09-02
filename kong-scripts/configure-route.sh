echo "Running Kong Auto Configuration Script - Please pay attemption at outputs for valuabe information"
line="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

KONG_HOST="http://localhost"
KONG_PORT="8001"
KONG_URL="$KONG_HOST:$KONG_PORT"

#Plugins Names
KEY_AUTH='key-auth'
TCP_LOG='tcp-log'
ACL='acl'
#RATE_LIMITING='rate-limiting-advanced'
RATE_LIMITING='rate-limiting'

#Functions
resource_Create(){
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local RESOURCE_URL=$3

    echo "Resource - Crations of Resource:${RESOURCE_NAME} with Type:${RESOURCE_TYPE} and URL:${RESOURCE_URL}"
    curl -i -X POST --url "$KONG_URL/${RESOURCE_TYPE}s" --data "name=${RESOURCE_NAME}" --data "url=${RESOURCE_URL}"

    return $?
}

resource_ConfigurePaths(){
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local RESOURCE_METHODS=$3
    local RESOURCE_PATHS=$4

    echo "Routes - Adding Routes:${RESOURCE_PATHS} for Resource:${RESOURCE_NAME} with Type:${RESOURCE_TYPE}"
    curl -i -X POST --url "$KONG_URL/${RESOURCE_TYPE}s/${RESOURCE_NAME}/routes" --data "methods[]=${RESOURCE_METHODS}" --data "paths[]=${RESOURCE_PATHS}"
    
    return $?
}

keyAuth_registerResource(){
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local URL="${KONG_URL}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "${KEY_AUTH} - Register Resource:${RESOURCE_NAME} with Type:${RESOURCE_TYPE}"
    curl -i -X POST --url ${URL} --data "name=${KEY_AUTH}" --data 'config.hide_credentials=false'

    return $?
}

keyAuth_registerConsumer(){
    local KEY_AUTH_CONSUMER=$1

    echo "${KEY_AUTH} - Registering Consumer:${KEY_AUTH_CONSUMER}"
    curl -i -X POST --url "${KONG_URL}/consumers" --data "username=${KEY_AUTH_CONSUMER}"

    return $?
}

keyAuth_registerKey(){
    local KEY_AUTH_CONSUMER=$1
    local KEY_AUTH_KEY=$2
    local URL="${KONG_URL}/consumers/${KEY_AUTH_CONSUMER}/${KEY_AUTH}"

    echo "${KEY_AUTH} - Adding Key:${KEY_AUTH_KEY} for Consumer:${KEY_AUTH_CONSUMER}"
    curl -i -X POST --url "${URL}" --data "key=${KEY_AUTH_KEY}"

    return $?
}

tcpLOG_registerResource(){        
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local TCP_LOG_HOST=$3
    local TCP_LOG_PORT=$4

    local URL="${KONG_URL}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "${TCP_LOG} - Registering Resource:${RESOURCE_NAME} with Type:${RESOURCE_TYPE} and Logging to ${TCP_LOG_HOST}:${TCP_LOG_PORT}"
    curl -i -X POST --url ${URL} --data "name=${TCP_LOG}" --data "config.host=${TCP_LOG_HOST}" --data "config.port=${TCP_LOG_PORT}"

    return $?
}

ACL_configureResource(){
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local ACL_LIST_NAME=$3
    local ACL_GROUPS_NAMES=$4
    local URL="${KONG_URL}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "${ACL} - Adding to ${ACL_LIST_NAME} Groups:${ACL_GROUPS_NAMES}"
    curl -i -X POST --url ${URL} --data "name=${ACL}" --data "config.${ACL_LIST_NAME}=${ACL_GROUPS_NAMES}"

    return $?
}

ACL_configureConsumer(){
    local ACL_CONSUMER=$1
    local ACL_GROUP=$2
    local URL="${KONG_URL}/consumers/${ACL_CONSUMER}/acls"

    echo "${ACL} - Registering ${ACL_CONSUMER} as Consumer of Group:${ACL_GROUP}"
    curl -X POST --url ${URL} --data "group=${ACL_GROUP}"

    return $?
}

rateLimiting_configureResource(){
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local RATE_LIMITING_UNIT=$3
    local RATE_LIMITING_AMOUNT=$4
    local URL="${KONG_URL}/${RESOURCE_TYPE}s/${RESOURCE_NAME}/plugins"

    echo "${RATE_LIMITING} - Adding to Resource:${RESOURCE_NAME} with Type:${RESOURCE_TYPE}, Limited At ${RATE_LIMITING_AMOUNT}/${RATE_LIMITING_UNIT}"    
    echo "config.${RATE_LIMITING_UNIT}=${RATE_LIMITING_AMOUNT}"
    curl -X POST --url ${URL} --data "name=${RATE_LIMITING}" --data "config.${RATE_LIMITING_UNIT}=${RATE_LIMITING_AMOUNT}"
    
    return $?
}

#TYPE='service'
#NAME='httpbin'
#RESOURCE_URL='https://httpbin.org/headers'
#METHODS='GET'
#CONSUMER='cliente'
#GROUP='GrupinhoShow'
#KEY='ChaveDeAcesso'
#LOG_HOST='elk'
#LOG_PORT='9200'

while getopts K:t:n:u:m:p:c:k:bg:l:P ARG; do
  case "$ARG" in
    K) KONG_URL="${OPTARG}" ;;
    t) TYPE="${OPTARG}" ;;
    n) NAME="${OPTARG}" ;;
    u) RESOURCE_URL="${OPTARG}" ;;
    m) METHODS="${OPTARG}" ;;
    p) PATHS="${OPTARG}" ;;
    c) CONSUMER="${OPTARG}" ;;
    k) KEY="${OPTARG}" ;;
    b) LIST_TYPE='blacklsit' ;;
    g) GROUP="${OPTARG}" ;;
    l) LOG_HOST="${OPTARG}" ;;
    P) LOG_PORT="${OPTARG}" ;;
  esac
done

if [ -z ${NAME+x} ] || [ -z ${RESOURCE_URL+x} ]
then

    if [ -z ${TYPE} ]
    then
        TYPE='service'
    fi

    sh ./usage/usage-geral.sh
    exit 1
else 
    resource_Create ${TYPE} ${NAME} ${RESOURCE_URL} # Type, ResourceName, ServiceAddress ({Protocol}://{Host}:{Port})
fi

if [ -z ${METHODS+x} ] || [ -z ${PATHS+x} ]
then
    echo "No Paths Will be Registered for ${NAME}... Skipping..."
    sleep 3
else 
    resource_ConfigurePaths ${TYPE} ${NAME} ${METHODS} ${PATHS} # Type, ResourceName, Methods (GET,POST,PUT,DELETE)
fi

if [ -z ${CONSUMER+x} ]
then
    echo "No Cosumer, so no Key-Auth Will Be Configured... Skipping..."
    sleep 3
else
    if [ -z ${KEY} ]
    then
        KEY=''
    fi
    keyAuth_registerResource ${TYPE} ${NAME} # Type, ResourceName
    keyAuth_registerConsumer ${CONSUMER} # ConsumerName
    keyAuth_registerKey ${CONSUMER} ${KEY} # ConsumerName, Key
fi

if [ -z ${GROUP+x} ] || [ -z ${CONSUMER+x} ]
then
    echo "No Group or Consumer to Configure ACL... Skipping..."
    sleep 3
else
    if [ -z ${LIST_TYPE} ]
    then
        LIST_TYPE='whitelist'
    fi
    ACL_configureResource ${TYPE} ${NAME} ${LIST_TYPE} ${GROUP} # Type, ResourceName, ListType (whitelist|blacklist), GroupName
    ACL_configureConsumer ${CONSUMER} ${GROUP}
fi

if [ -z ${LOG_HOST+x} ] || [ -z ${LOG_PORT+x} ]
then
    echo "No Log Host or Port... Skipping..."
    sleep 3
else
    tcpLOG_registerResource ${TYPE} ${NAME} ${LOG_HOST} ${LOG_PORT} # Type, ResourceName, LoggingAddress, LoggingPort
fi

#rateLimiting_configureResource ${TYPE} ${NAME} 'second' '5'