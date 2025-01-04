#!/bin/bash

RELEASE_ID=$1
FILE=$2

curl -s -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$FILE \
  --data-binary "@$FILE"
