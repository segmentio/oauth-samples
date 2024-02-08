#!/bin/bash

############################################################################
# This script is used to send a sample message to Tracking API using OAuth.
#
# It takes the following parameters:
#
# -j <access_jwt_token> : access_jwt_token generated using generate-access-token.sh. Required if OAuth is on
# -w <write_key> : write_key of the OAuth enabled source
# -h <host> : Host of the Tracking server. It should be either https://api.segment.io or https://events.eu1.segmentapis.com. Defaults to https://api.segment.io
# -o <oauth> : OAuth on or off. Defaults to OAuth on
# -v <verbose> : Verbose mode. It should be either on or off.  Defaults to off
#
# Example :
# Send non-OAuth request
# ./send-tapi-request.sh -w <write_key> -o off -v on
#
# Send OAuth request
# ./send-tapi-request.sh -w <write_key> -j <access_jwt_token> -o on -v on
#
############################################################################

USAGE="Usage: $0 -w <write_key> [-j <access_jwt_token>] [-h https://api.segment.io|https://events.eu1.segmentapis.com] [-o on|off] [-v on|off]"

verbose=""
oauth=1
host="https://api.segment.io"
# Parse input arguments
while getopts ":h:j:o:v:w:" option; do
  case $option in
    h)
      host="$OPTARG"
      if [ "$host" != "https://api.segment.io" ] && [ "$host" != "https://events.eu1.segmentapis.com" ]; then
        echo "Invalid host $host"
        exit 1
      fi
      ;;
    j)
      jwt="$OPTARG"
      ;;
    o)
      oauth_mode="$OPTARG"
      if [[ "$oauth_mode" == "on" ]]; then
        oauth=1
      elif [[ "$oauth_mode" == "off" ]]; then
        oauth=0
      else
        echo "Invalid oauth $oauth_mode"
        exit 1
      fi
      ;;
    w)
      write_key="$OPTARG"
      ;;
    v)
      verbose_mode="$OPTARG"
      if [[ "$verbose_mode" == "on" ]]; then
        verbose="-v"
      elif [[ "$verbose_mode" == "off" ]]; then
        verbose=""
      else
        echo "Invalid verbose $verbose_mode"
        exit 1
      fi
      ;;
    *)
      echo "${USAGE}"
      exit 1
      ;;
  esac
done

# Validate input arguments
if [ $oauth -eq 1 ] && [ -z "$jwt" ]; then
    echo "access_jwt_token is required when OAuth is on"
    exit 1
fi

if [ -z "$write_key" ]; then
    echo "${USAGE}"
    exit 1
fi


MSG_ID=$(uuidgen)

AUTH_HEADER="Authorization: Basic $(echo "$write_key:" | base64)"
if [ $oauth -eq 1 ]; then
  AUTH_HEADER="Authorization: Bearer $jwt"
fi

if [ ! -z "$verbose" ]; then
  echo "Using Message Id :$MSG_ID"
  echo "Using Write Key   :$write_key"
  echo "Using Auth Header :$AUTH_HEADER"
fi

curl $verbose  --url "${host}/v1/track" \
  --header "$AUTH_HEADER" \
  --header 'Content-Type: application/json' \
  --data '{
	"event": "happy-path-event",
	"email": "test@example.org",
	"messageId": "'"$MSG_ID"'",
	"userId": "'"123"'",
	"writeKey": "'"$write_key"'"
}
'
