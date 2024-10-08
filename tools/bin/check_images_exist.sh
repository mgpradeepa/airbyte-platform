#!/usr/bin/env bash

# ------------- Import some defaults for the shell

# Source shell defaults
# $0 is the currently running program (this file)
this_file_directory=$(dirname $0)
relative_path_to_defaults=$this_file_directory/../shell_defaults

# if a file exists there, source it. otherwise complain
if test -f $relative_path_to_defaults; then
  # source and '.' are the same program
  source $relative_path_to_defaults
else
  echo -e "\033[31m\nFAILED TO SOURCE TEST RUNNING OPTIONS.\033[39m"
  echo -e "\033[31mTried $relative_path_to_defaults\033[39m"
  exit 1
fi

set +o xtrace  # +x easier human reading here

. tools/lib/lib.sh

function check_chart_image_exist() {
  printf "\nCalling check_chart_image_exists with tag $1...\n"
  local tag=$1

  images=($(grep "repository: airbyte/" "$this_file_directory/../../charts/airbyte/values.yaml" | tr -d ' ' | cut -d ':' -f2))
  for img in "${images[@]}";
  do
      printf "\t${img}:${tag}\n"
      if docker_tag_exists $img $tag; then
        printf "\tSTATUS: found\n\n"
      else
        printf "\tERROR: not found!\n\n" && exit 1
      fi
  done
}

function docker_tag_exists() {
  # Is true for images stored in the Github Container Registry
  repo=$1
  tag=$2
  # we user [[ here because test doesn't support globbing well
  if [[ $repo == ghcr* ]]
  then
    TOKEN_URL=https://ghcr.io/token\?scope\="repository:$1:pull"
    token=$(curl $TOKEN_URL | jq -r '.token' > /dev/null)
    URL=https://ghcr.io/v2/$1/manifests/$2
    echo -e "$blue_text""\tURL: $URL""$default_text"
    curl -H "Authorization: Bearer $token" --location --silent --show-error --dump-header header.txt "$URL" > /dev/null
    curl_success=$?
  else
    URL=https://hub.docker.com/v2/repositories/"$1"/tags/"$2"
    echo -e "$blue_text""\tURL: $URL""$default_text"
    curl --silent --show-error --location --dump-header header.txt "$URL" > /dev/null
    curl_success=$?
    # some bullshit to get the number out of a header that looks like this
    # < content-length: 1039
    # < x-ratelimit-limit: 180
    # < x-ratelimit-reset: 1665683196
    # < x-ratelimit-remaining: 180
    docker_rate_limit_remaining=$(grep 'x-ratelimit-remaining: ' header.txt | grep --only-matching --extended-regexp "\d+")
    # too noisy when set to < 1.  Dockerhub starts complaining somewhere around 10
    if test "$docker_rate_limit_remaining" -lt 20; then
      echo -e "$red_text""We are close to a sensitive dockerhub rate limit!""$default_text"
      echo -e "$red_text""SLEEPING 60s sad times""$default_text"
      sleep 60
      docker_tag_exists $1 $2
    elif test $docker_rate_limit_remaining -lt 50; then
      echo -e "$red_text""Rate limit reported as $docker_rate_limit_remaining""$default_text"
    fi
  fi
  if test $curl_success -ne 0; then
    echo -e "$red_text""Curl Said this didn't work.  Please investigate""$default_text"
    exit 1
  fi
}

checkPlatformImages() {
  echo -e "$blue_text""Checking platform images exist...""$default_text"
  # Check dockerhub to see if the images exist
  check_chart_image_exist "$VERSION"
}


main() {
  assert_root

  SUBSET=${1:-all} # default to all.
  [[ ! "$SUBSET" =~ ^(all|platform)$ ]] && echo "Usage ./tools/bin/check_image_exists.sh [all|platform]" && exit 1
  echo -e "$blue_text""checking images for: $SUBSET""$default_text"

  [[ "$SUBSET" =~ ^(all|platform)$ ]] && checkPlatformImages
  echo -e "$blue_text""Image check complete.""$default_text"
  test -f header.txt     && rm header.txt
}

main "$@"