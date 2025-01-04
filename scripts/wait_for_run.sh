#!/bin/bash

RUN_ID=$1
MINUTES=$2

resp=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/actions/runs/$RUN_ID)


echo "Waiting for ID: $RUN_ID" 2>&2
success=0
finished=0
status=""
TOTAL_SECS=$((MINUTES * 60))
SECS=0
INTERVAL=15
while [ "$status" != "completed" ] && [ $SECS -le $TOTAL_SECS ] && [ $finished -eq 0 ]
do
    printf "Iteration %02d:%02d / %02d:%02d\n" $((SECS / 60)) $((SECS % 60)) $((TOTAL_SECS / 60)) $((TOTAL_SECS % 60)) >&2
    SECS=$((SECS + INTERVAL))
    
    resp=$(
            curl -s -L \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer $TOKEN" \
              -H "X-GitHub-Api-Version: 2022-11-28" \
              https://api.github.com/repos/$REPO/actions/runs/$RUN_ID
        )
    status=$(echo $resp | jq -r '.status')
    result=$(echo $resp | jq -r '.conclusion')
    echo "Status: $status, result: $result" >&2
    if [ "$status" == "completed" ] && [ "$result" != "success" ]
    then
        echo "Run has failed: $RUN_ID"
        finished=1
    else
        if [ "$status" != "completed" ]
        then
            sleep 15
        else
            finished=1
            success=1
        fi
    fi
done

if [ $success -eq 1 ]
then
    echo "Run $RUN_ID finished successfully." >&2
else
    echo "Run $RUN_ID failed." >&2
fi
echo $success
