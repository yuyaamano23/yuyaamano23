#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

RESULT=$(
  curl https://zenn.dev/yuyaamano23/feed 2>/dev/null |
    grep -oE '(<title>.*?</title>|<link>.*?</link>)' |
    sed 1,4d |
    awk '{
      if(NR%2){
        line=$0
      }else{
        print line $0;
        line=""
      }
    }END{
      if(line)
        print line
      }' |
    sed -e "s/<title><\!\[CDATA\[\(.*\)\]\]><\/title><link>\(.*\)<\/link>/- [\1](\2)/" |
    sed -n 1,5p
)

sed -i -z 's|<\!-- LATEST_ARTICLES_START -->.*<!-- LATEST_ARTICLES_END -->|<!-- LATEST_ARTICLES_START -->|g' ./README.md

echo "$RESULT" | while read -r line; do
  echo "$line" >>./README.md
done

echo '<!-- LATEST_ARTICLES_END -->' >>./README.md