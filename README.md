# oauth-samples
This repository contains samples scripts to help get started with the OAuth authentication for Segment APIs.

## Shell Examples
Shell script examples can be found in [shell](shell) directory. These scripts are written in bash and can be run in any bash environment.

1. [Create Private/Public Key Pair](shell/create-keypair.sh)

Creates a private and public key pair using openssl. The private key is used to sign the JWT and the public key is used to verify the JWT.

```shell
./create-keypair.sh -s sample
```

2. [Generate Access Token](shell/generate-access-token.sh)

Generates a JWT access token using the private key for the OAuth app id created in Segment UI and associated with public key id.

```shell
./generate-access-token.sh -a 2c3y07DGjEFeTIchtLQaFZ9NDCf -i 2c4EEVxBkmVyJcNsvbapt846Qik -k private-sample.pem -h https://oauth2.segment.io -v on
```

3. [Send Request to Tracking API](shell/send-tapi-request.sh)

Sends a request to the Segment Tracking API using the generated access token.

```shell
./send-tapi-request.sh -w <write-key> -j <access-jwt-token> -h https://api.segment.io -o on
```

4. [Decode JWT Token](shell/decode-jwt.sh)

Decodes JWT token.

```shell
./decode-jwt.sh -j <jwt-token>
```
