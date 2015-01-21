#!/bin/bash

# set -x # for debugging

access_token=""

#### CORE FUNCTIONS

gh_request()
{
  local gh_request_route=$@
  if [ -n "$access_token" ]
  then
    curl -s -G "https://api.github.com/$gh_request_route" -H "User-Agent: nathos/ghinfo" -H "Accept: application/vnd.github.full+json" -H "Authorization: token $access_token"
  else
    curl -s -G "https://api.github.com/$gh_request_route" -H "User-Agent: nathos/ghinfo" -H "Accept: application/vnd.github.full+json"
  fi
}

api_request()
{
  IFS="" # Disable space as an array delimiter
  local api_request_result=$( gh_request "$1") # only make a single API request
  shift

  api_request_filtered=() # initialize/empty filtered results array

  # loop through all requested jq filter arguments
  while [ "$1" ]; do
    api_request_filtered+=( $( echo $api_request_result | jq -r "$1" )) # append to filtered result array
    shift
  done

  unset IFS
}

jq_test()
{
  hash jq 2>/dev/null || { echo -e "\n\033[31mERROR:\033[0m I require the \033[1;33mjq\033[0m command but it's not installed.\n"; exit 1; } # test that `jq` is installed
}

#### FORMATTED REQUEST FUNCTIONS
#    Uses format: `api_request 'API_ROUTE' 'FILTER1' 'FILTER2' ...`

login_and_name()
{
  api_request 'users/nathos' '.login' '.name'
  echo "Login: ${api_request_filtered[0]}"
  echo "Name: ${api_request_filtered[1]}"
}

user_details()
{
  api_request "users/$username" '.login' '.name'
  echo "Login: ${api_request_filtered[0]}"
  echo "Name: ${api_request_filtered[1]}"
  exit
}



#### MAIN

jq_test

while [ "$1" != "" ]; do
  case $1 in
    -t | --token )  shift
                    access_token="$1" ;;
    -u | --user )   shift
                    username="$1"
                    user_details
  esac
  shift
done

exit
