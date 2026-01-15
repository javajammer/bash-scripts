#!/bin/bash

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

if output=$(timeout 3 openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" -no_tls1_3 -no_ticket -no_renegotiation  </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null); then
    expiry=$(echo "$output" | awk -F'=' '/notAfter/ {print $2}')
    if [ -n "$expiry" ]; then
        echo "SSL cert for $DOMAIN expired at: $expiry"
    fi
else
	echo "ERROR: Timeout(3s) or connection failed"
fi
