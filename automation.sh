#!/bin/bash

USERNAME="${USERNAME}"
ACCESS_KEY="${ACCESS_KEY}"

TEST_IDS=(
    "2aa1c99e-0581-49f6-8a63-f4cfc334cd8d"
)

for TEST_ID in "${TEST_IDS[@]}"
do
     CODE_NAME="py-sele-$(date +%Y%m%d%H%M%S)" # Generate dynamic code_name
    echo "Calling API for Test ID: $TEST_ID with code_name: $CODE_NAME"
    curl "https://stage-test-manager-api.lambdatestinternal.com/api/atm/v1/test/$TEST_ID/code" \
        -u "$USERNAME:$ACCESS_KEY" \
        -H 'accept: application/json' \
        -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
        -H 'cache-control: no-cache' \
        -H 'content-type: application/json' \
        -H 'origin: https://stage-test-manager.lambdatestinternal.com' \
        -H 'pragma: no-cache' \
        -H 'priority: u=1, i' \
        -H 'referer: https://stage-test-manager.lambdatestinternal.com/' \
        -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
        -H 'sec-ch-ua-mobile: ?0' \
        -H 'sec-ch-ua-platform: "macOS"' \
        -H 'sec-fetch-dest: empty' \
        -H 'sec-fetch-mode: cors' \
        -H 'sec-fetch-site: same-site' \
        -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
        --data-raw "{\"code_name\":\"$CODE_NAME\",\"language\":\"python\",\"framework\":\"selenium\",\"folder_name\":\"\",\"accessibility\":\"false\"}"
    echo -e "\nDone with $TEST_ID"

    STATUS=""
    while true; do
        echo "Checking status for Test ID: $TEST_ID"
        RESPONSE=$(curl -s "https://stage-test-manager-api.lambdatestinternal.com/api/atm/v1/test/$TEST_ID/codes?page=1&per_page=10&filter%5Bcode_name%5D=&sort_by=committed_at" \
            -u "$USERNAME:$ACCESS_KEY" \
            -H 'accept: application/json' \
            -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
            -H 'origin: https://stage-kaneai.lambdatestinternal.com' \
            -H 'priority: u=1, i' \
            -H 'referer: https://stage-kaneai.lambdatestinternal.com/' \
            -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
            -H 'sec-ch-ua-mobile: ?0' \
            -H 'sec-ch-ua-platform: "macOS"' \
            -H 'sec-fetch-dest: empty' \
            -H 'sec-fetch-mode: cors' \
            -H 'sec-fetch-site: same-site' \
            -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36')

        STATUS=$(echo "$RESPONSE" | jq -r '.data[0].status') # Extracting 'status' from the first object in 'data'

        if [[ "$STATUS" == "success" || "$STATUS" == "error" ]]; then
            echo "Test ID: $TEST_ID completed with status: $STATUS"
             if [[ "$STATUS" == "success" ]]; then
                echo "Code Generation Successful"
            else
                echo "Code Generation Failed"
            fi
            break
        fi
        echo "Status: $STATUS. Retrying in 15 seconds..."
        sleep 15
    done
done