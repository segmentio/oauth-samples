#!/bin/zsh

############################################################################
# This script is used to generate private and public key pairs.
# The private key needs to be secured locally and the public key needs to be registered with the OAuth application.
#
# It takes the following parameters:
#
# -s <suffix> : suffix to be appended to the private and public key file names. Defaults to empty string
#
# Example :
# ./create-keypair.sh -s test
#
############################################################################

USAGE="Usage: $0 -s [<suffix>]"

suffix=""
# Parse input arguments
while getopts ":s:" option; do
  case $option in
    s)
      suffix="-$OPTARG"
      ;;
    *)
      echo "${USAGE}"
      exit 1
      ;;
  esac
done

PRIVATE_KEY_FILE="private${suffix}.pem"
PUBLIC_KEY_FILE="public${suffix}.pem"

# Validate if the private and public key files already exist
if [[ -f "$PRIVATE_KEY_FILE" ]]; then
  echo "Private key file $PRIVATE_KEY_FILE already exists. Please remove it and try again or choose a different suffix."
  exit 1
fi

if [[ -f "$PUBLIC_KEY_FILE" ]]; then
  echo "Public key file $PUBLIC_KEY_FILE already exists. Please remove it and try again or choose a different suffix."
  exit 1
fi

# Generate private and public key pairs
openssl genpkey -algorithm RSA -out "${PRIVATE_KEY_FILE}" -pkeyopt rsa_keygen_bits:2048
openssl rsa -in "${PRIVATE_KEY_FILE}" -pubout -outform PEM -out "${PUBLIC_KEY_FILE}"

echo "Created $PRIVATE_KEY_FILE and $PUBLIC_KEY_FILE."
echo "Please secure the $PRIVATE_KEY_FILE locally and register the $PUBLIC_KEY_FILE with the OAuth application."
