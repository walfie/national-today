#!/bin/bash

set -euxo pipefail

INPUT=$(mktemp)

cleanup() {
  rm "$INPUT"
}

trap cleanup EXIT

DATE=$(date +%B-%-d | tr '[:upper:]' '[:lower:]')
curl "https://nationaltoday.com/$DATE/" >$INPUT

MONTH=$(pup '.ntdb-holiday-day text{}' <$INPUT | tr '[:upper:]' '[:lower:]' | sed -n 1p)
DAY="$(pup '.ntdb-holiday-date text{}' <$INPUT | sed -n 1p)"

OUTPUT="public/$MONTH/$DAY.json"

mkdir -p $(dirname $OUTPUT)

pup '.card-holiday-title json{}' <$INPUT \
  | jq "{
    month: \"$MONTH\",
    day: $DAY,
    holidays: map({ title: .text, description: null })
  }" >$OUTPUT

ln -sf "$MONTH/$DAY.json" public/today.json

echo $OUTPUT

