#!/bin/bash

URL="http://<ec2-public-ip>"

STATUS=$(curl -o /dev/null -s -w "%{http_code}" $URL)

if [ "$STATUS" -ne 200 ]; then
  echo "Deployment validation failed! HTTP Status: $STATUS"
  exit 1
fi

echo "Deployment validation succeeded!"
