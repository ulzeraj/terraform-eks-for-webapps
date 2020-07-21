#!/bin/bash
# For MacOS and FreeBSD replace tac with 'tail' -r.

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PROGRAM="tac"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PROGRAM="tail -r"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    PROGRAM="tail -r"
fi

THUMBPRINT=$(echo | openssl s_client -servername oidc.eks.${1}.amazonaws.com -showcerts -connect oidc.eks.${1}.amazonaws.com:443 2>&- | ${PROGRAM} | sed -n '/-----END CERTIFICATE-----/,/-----BEGIN CERTIFICATE-----/p; /-----BEGIN CERTIFICATE-----/q' | ${PROGRAM} | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo ${THUMBPRINT_JSON}
