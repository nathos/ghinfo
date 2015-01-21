#!/bin/bash


#### CORE FUNCTIONS

gh_request()
{
  local gh_request_route=$@
  curl -s -G "https://api.github.com/$gh_request_route" -H "Accept: application/vnd.github.full+json"
  # echo "Request Route: $gh_request_route"
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


#### FORMATTED REQUEST FUNCTIONS
#    Uses format: `api_request 'API_ROUTE' 'FILTER1' 'FILTER2' ...`

login_and_name()
{
  api_request 'users/nathos' '.login' '.name'
  echo "Login: ${api_request_filtered[0]}"
  echo "Name: ${api_request_filtered[1]}"
}



#### MAIN

while [ "$1" != "" ]; do
  case $1 in
    -t | --token )  shift
                    access_token=$1
  esac
  shift
done

login_and_name


exit
