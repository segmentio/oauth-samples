#!/bin/zsh

############################################################################
# This script decodes a JWT token and prints the decoded token.
#
# It takes the following parameters:
#
# -j <jwt-token> : jwt token to be decoded
#
# Example :
# ./decode-jwt.sh -j <jwt-token>
#
############################################################################

USAGE="Usage: $0 -j <jwt-token"

JWT=""

# Parse input arguments
while getopts ":j:" option; do
  case $option in
    j)
      JWT="$OPTARG"
      ;;
    *)
      echo "${USAGE}"
      exit 1
      ;;
  esac
done

if [[ -z "$JWT" ]]; then
  echo "${USAGE}"
  exit 1
fi

if [[ -n "$BASH_VERSINFO" ]]; then
  TOKENS=(${JWT//./ })
  HEADER=${TOKENS[0]}
  PAYLOAD=${TOKENS[1]}
  SIGNATURE=${TOKENS[2]}
elif [[ -n "$ZSH_VERSION" ]]; then
  TOKENS=(${(@s/./)JWT})
  HEADER=${TOKENS[1]}
  PAYLOAD=${TOKENS[2]}
  SIGNATURE=${TOKENS[3]}
else
  echo "Your shell is not supported"
  exit 1
fi

HEADER_JSON=$(echo "$HEADER" | basenc -id --base64url 2> /dev/null)
PAYLOAD_JSON=$(echo "$PAYLOAD" | basenc -id --base64url 2> /dev/null)

echo "Header  : ${HEADER_JSON}"
echo "Payload : ${PAYLOAD_JSON}"

