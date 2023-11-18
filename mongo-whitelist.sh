#!/usr/bin/env bash

# -- ENV -- #
# SERVICE_NAME
# MONGO_ATLAS_API_PK
# MONGO_ATLAS_API_SK
# MONGO_ATLAS_API_PROJECT_ID
# -- ENV -- #

set -e

check_for_deps() {
  deps=(
    atlas
    bash
    curl
    jq
  )

 for dep in "$${deps[@]}"; do
   if [ ! "$(command -v $dep)" ]
   then
    echo "dependency [$dep] not found. exiting"
    exit 1
   fi
 done
}

get_service_ip() {
  curl -s http://169.254.169.254/latest/meta-data/public-ipv4
}

get_previous_service_ip() {
  local previous_ip=$(atlas accessLists list -o json \
                      | jq --arg SERVICE_NAME "$SERVICE_NAME" -r \
                        '.results[]? as $results | $results.comment | if test("\\[\($SERVICE_NAME)\\]") then $results.ipAddress else empty end'
                    )

  echo "$previous_ip"
}

whitelist_service_ip() {
  local current_service_ip="$1"
  local comment="Hosted IP of [$SERVICE_NAME] [set@$(date +%s)]"

  if (( "$${#comment}" > 80 )); then
    echo "comment field value will be above 80 char limit: \"$comment\""
    echo "comment would be too long due to length of service name [$SERVICE_NAME] [$${#SERVICE_NAME}]"
    echo "change comment format or service name then retry. exiting to avoid mongo API failure"
    exit 1
  fi

  echo "whitelisting service IP [$current_service_ip] with comment value: \"$comment\""

  atlas accessLists create --currentIp --comment "$comment"
}

delete_previous_service_ip() {
  local previous_service_ip="$1"

  echo "deleting previous service IP address of [$SERVICE_NAME]"

  atlas accessLists delete "$previous_service_ip"
}

set_mongo_whitelist_for_service_ip() {
  local current_service_ip=$(get_service_ip)
  local previous_service_ip=$(get_previous_service_ip)

  if [[ -z "$previous_service_ip" ]]; then
    echo "service [$SERVICE_NAME] has not yet been whitelisted"

    whitelist_service_ip "$current_service_ip"
  elif [[ "$current_service_ip" == "$previous_service_ip" ]]; then
    echo "service [$SERVICE_NAME] IP has not changed"
  else
    echo "service [$SERVICE_NAME] IP has changed from [$previous_service_ip] to [$current_service_ip]"

    delete_previous_service_ip "$previous_service_ip"
    whitelist_service_ip "$current_service_ip"
  fi
}

get_ssm_parameter() {
  local param_name="$1"
  aws --region="$EC2_REGION" ssm get-parameter --name $param_name | jq -r '.Parameter.Value'
}

yum install -y jq mongodb-atlas-cli

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"

export SERVICE_NAME=${SERVICE_NAME}

export MONGODB_ATLAS_PUBLIC_API_KEY=$(get_ssm_parameter "${MONGODB_ATLAS_PUBLIC_API_KEY}")
export MONGODB_ATLAS_PRIVATE_API_KEY=$(get_ssm_parameter "${MONGODB_ATLAS_PRIVATE_API_KEY}")
export MONGODB_ATLAS_ORG_ID=${MONGODB_ATLAS_ORG_ID}
export MONGODB_ATLAS_PROJECT_ID=${MONGODB_ATLAS_PROJECT_ID}

check_for_deps
set_mongo_whitelist_for_service_ip
