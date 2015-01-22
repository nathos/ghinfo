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
  local api_request_result=$( gh_request "$1") # only make a single API request
  shift

  api_request_filtered=() # initialize/empty filtered results array

  # loop through all requested jq filter arguments
  for arg in $* ; do
    _response=$( echo $api_request_result | jq -r "$arg" )
    if [[ -n $_response ]] ; then
      api_request_filtered+=("$_response") # append to filtered result array
    # else
    #   echo "No response for $arg"
    fi
  done

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
  if [ "$bio" != "null" ]; then
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

repo_details()
{
  echo -e "\n\033[0mDetails for repository \033[35m$repo\033[0m:"
  local name_length=${#repo}
  local header_length=$(( name_length + 24 ))
  for i in $(seq 1 $header_length); do
    echo -n "="
  done
  echo -e "\n"
  api_request "repos/$repo" '.name' '.owner.login' '.description' '.forks_count' '.stargazers_count' '.open_issues_count' '.created_at' '.updated_at' '.parent.name' '.parent.owner.login' '.clone_url' '.homepage'
  echo -e " \033[1m${api_request_filtered[0]}\033[0m by ${api_request_filtered[1]}\n"
  local description=${api_request_filtered[2]}
  if [ "$description" != "null" ]; then
    echo " $description" | fmt
    echo ""
  fi
  local homepage=${api_request_filtered[11]} # FIXME: dirty hack because GH returns an empty value instead of null
  if [[ -n $homepage ]]; then
    echo " Homepage: $homepage"
  fi
  echo -e "\n \033[35m$repo\033[0m has been forked \033[1;33m${api_request_filtered[3]}\033[0m times and starred \033[1;33m${api_request_filtered[4]}\033[0m times.\n"
  for i in $(seq 1 $name_length); do
    echo -n " "
  done
  echo -e "  it has \033[1;33m${api_request_filtered[5]}\033[0m open issues.\n"
  for i in $(seq 1 $name_length); do
    echo -n " "
  done
  local created_at=${api_request_filtered[6]}
  local updated_at=${api_request_filtered[7]}
  echo -e "  was created on \033[1;33m${created_at:0:10}\033[0m and last updated on \033[1;33m${updated_at:0:10}\033[0m."
  local parent_name=${api_request_filtered[8]}
  local parent_owner=${api_request_filtered[9]}
  if [ $parent_name != "null" ]; then
    echo -e "\n\n \033[35m${api_request_filtered[0]}\033[0m was forked from \033[33m$parent_name\033[0m by \033[33m$parent_owner\033[0m"
  fi
  echo -e "\n Clone URL: ${api_request_filtered[10]}"

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
                    user_details ;;
    -r | --repo )   shift
                    repo="$1"
                    repo_details
  esac
  shift
done

exit
