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

user_details()
{
  echo -e "\n\033[0mDetails for GitHub user \033[35m$username\033[0m:"
  local name_length=${#username}
  local header_length=$(( name_length + 25 ))
  for i in $(seq 1 $header_length); do
    echo -n "="
  done
  echo -e "\n"
  api_request "users/$username" '.name' '.location' '.email' '.bio' '.public_repos' '.public_gists' '.followers' '.following' '.created_at'
  echo "     Name: ${api_request_filtered[0]}"
  echo " Location: ${api_request_filtered[1]}"
  local email=${api_request_filtered[2]}
  if [ $email != "null" ]; then
    echo "    Email: $email"
  fi
  local bio=${api_request_filtered[3]}
  if [ $bio != "null" ]; then
    echo "      Bio: $bio"
  fi
  echo -e "\n"
  echo -e " \033[35m$username\033[0m has shared \033[1;33m${api_request_filtered[4]}\033[0m public git repositories and \033[1;33m${api_request_filtered[5]}\033[0m gists.\n"
  local user_since=${api_request_filtered[8]}
  for i in $(seq 1 $name_length); do
    echo -n " "
  done
  echo -e "  is followed by \033[1;33m${api_request_filtered[6]}\033[0m GitHub users and follows \033[1;33m${api_request_filtered[7]}\033[0m users.\n"
  for i in $(seq 1 $name_length); do
    echo -n " "
  done
  echo -e "  has been a happy GitHub user since \033[1;33m${user_since:0:10}\033[0m."
  echo ""
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
