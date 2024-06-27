#!/bin/bash

############################################################################
# This script is used to generate an access token for the Segment API.
#
# It takes the following parameters:
#
# -a <oauth-app-id> : OAuth Application ID created in the Segment UI. Please see https://segment.com/docs/connections/oauth/#create-an-oauth-app
# -i <public-key-id> : Public key ID registered with the OAuth application.
# -k <private-key.pem> : Private key file secured locally and corresponds to the public key ID.
# -h <host> : Host of the OAuth Authorization server. It should be either https://oauth2.segment.io or https://oauth2.eu1.segmentapis.com. Defaults to https://oauth2.segment.io
# -s <scope> : Space separated list of scopes. For example "tracking_api:write functions:write". Defaults to tracking_api:write
# -v <verbose> : Verbose mode. It should be either on or off.  Defaults to off
#
# Example :
#
# Oregon
# ./generate-access-token.sh -a 2SlCeDJfbcFsNBXeIk90gS0eg0M -i 2SlCeEpaovMXv2EOMPfSWE4at97  -k privatekey.pem  -h https://oauth2.segment.io -v on
#
# Dublin
# ./generate-access-token.sh -a 2SlCeDJfbcFsNBXeIk90gS0eg0M -i 2SlCeEpaovMXv2EOMPfSWE4at97  -k privatekey.pem -h https://oauth2.eu1.segmentapis.com -v on
#
############################################################################
scopes="tracking_api:write"
host="https://oauth2.segment.io"
verbose=0
USAGE="Usage: $0 -a <oauth-app-id> -i <public-key-id> -k <private-key.pem> -h [https://oauth2.segment.io|https://oauth2.eu1.segmentapis.com] [-s <scope>] [-v on|off]"

# Parse input arguments
while getopts ":a:i:k:h:s:v:" option; do
  case $option in
    a)
      app_id="$OPTARG"
      ;;
    i)
      key_id="$OPTARG"
      ;;
    k)
      if [ -f "$OPTARG" ]; then
        key_file_name="$OPTARG"
      else
        echo "Cannot find fle $OPTARG"
        exit 1
      fi
      ;;
    h)
      host="$OPTARG"
      if [ "$host" != "https://oauth2.segment.io" ] && [ "$host" != "https://oauth2.eu1.segmentapis.com" ]; then
        echo "Invalid host $host"
        exit 1
      fi
      ;;
    s)
      scopes="$OPTARG"
      ;;
    v)
      verbose_mode="$OPTARG"
      if [[ "$verbose_mode" == "on" ]]; then
        verbose=1
      elif [[ "$verbose_mode" == "off" ]]; then
        verbose=0
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
if [ -z "$key_file_name" ] || [ -z "$key_id" ]  || [ -z "$app_id" ] || [ -z "$scopes" ] || [ -z "$host" ]; then
    echo "${USAGE}"
    exit 1
fi

# Construct header portion of the JWT
HEADER_RAW='{"alg":"RS256", "typ":"JWT", "kid":"'$key_id'"}'
HEADER=$( echo -n "${HEADER_RAW}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

NOW=$( date +%s )
IAT=$NOW
EXP=$(($NOW + 60))
JTI=$RANDOM

# Construct payload portion of the JWT
PAYLOAD_RAW='{"iss":"'${app_id}'", "sub":"'${app_id}'", "aud":"'${host}'", "iat":"'${IAT}'","exp":"'${EXP}'","jti":"'${JTI}'"}'
PAYLOAD=$( echo -n "${PAYLOAD_RAW}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

# Combine header and payload to sign the JWT
HEADER_PAYLOAD="${HEADER}"."${PAYLOAD}"

# Sign the JWT using the private key
PEM=$( cat "$key_file_name" )
SIGNATURE=$( openssl dgst -sha256 -sign <(echo -n "${PEM}") <(echo -n "${HEADER_PAYLOAD}") | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

if [ -z "$SIGNATURE" ]; then
  echo "Failed to sign the JWT"
  exit 1
fi

# Combine Header, Payload and Signature to form the JWT
JWT="${HEADER_PAYLOAD}"."${SIGNATURE}"

if [ $verbose == 1 ]; then
  echo "-------------------------------------------------------------------------------"
  echo "Header          : ${HEADER_RAW}"
  echo "Payload         : ${PAYLOAD_RAW}"
  echo "Signature       : ${SIGNATURE}"
  echo "JWT             : ${JWT}"
  echo "-------------------------------------------------------------------------------"
fi

URI="${host}/token"

curl -s -X POST $URI -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
  --data-urlencode "client_assertion=${JWT}" \
  --data-urlencode "scope=${scopes}"

