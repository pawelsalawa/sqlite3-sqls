#!/bin/bash

WORKFLOW=$1
PAYLOAD=$2

curl -s -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW/dispatches \
  -d $PAYLOAD

url=https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW/runs
resp=$(
        curl -s -L \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $TOKEN" \
          -H "X-GitHub-Api-Version: 2022-11-28" \
          $url
      )
run_id=$(echo $resp | jq '.workflow_runs[0].id')
echo "Run ID for workflow $WORKFLOW: $run_id" >&2
if [ "$run_id" == "null" ]
then
    echo "Null Run ID for $wname." >&2
    exit 1
fi
echo $run_id

resp=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/actions/runs/$run_id)

# status=$(echo $resp | jq -r '.status')
# conclusion=$(echo $resp | jq -r '.conclusion')

# if [[ "$status" == "completed" ]]; then
  # if [[ "$conclusion" == "success" ]]; then
    # echo "Workflow completed successfully!"
    # break
  # else
    # echo "Workflow failed!"
    # exit 1
  # fi
# else
  # echo "Workflow is still running..."
  # sleep 10
# fi



echo "Waiting for ID: $run_id" 2>&2
url=https://api.github.com/repos/$REPO/actions/runs/$run_id
status=""
total_it=20
it=1
while [ "$status" != "completed" ] && [ $it -le $total_it ]
do
    echo "Iteration $it/$total_it..."
    it=$((it + 1))
    
    resp=$(
            curl -s -L \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
              -H "X-GitHub-Api-Version: 2022-11-28" \
              $url
        )
    status=$(echo $resp | jq -r '.status')
    result=$(echo $resp | jq -r '.conclusion')
    echo "Status: $status, result: $result"
    if [ "$status" == "completed" ] && [ "$result" != "success" ]
    then
        echo "Child build has failed: $url"
        exit 1
    fi

    if [ "$status" != "completed" ]
    then
        sleep 30
    else
        success=1
    fi
done

if [ $success -eq 1 ]
then
    echo "Child build $url finished successfully."
else
    echo "Child build $url failed."
    exit 1
fi
