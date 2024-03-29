#!/bin/bash

set -euxo pipefail

INPUT=$(mktemp)

cleanup() {
  rm "$INPUT"
}

trap cleanup EXIT

curl 'https://nationaltoday.com/today/' >$INPUT

MONTH=$(pup '.ntdb-holiday-day text{}' <$INPUT | tr '[:upper:]' '[:lower:]' | sed -n 1p)
DAY="$(pup '.ntdb-holiday-date text{}' <$INPUT | sed -n 1p)"

OUTPUT="public/$MONTH/$DAY.json"

mkdir -p $(dirname $OUTPUT)

pup '.title-box > :not(.holiday-date) json{}' <$INPUT \
  | jq "{
    month: \"$MONTH\",
    day: $DAY,
    holidays: map(.children | { title: .[0].children[0].text, description: .[1].text })
  }" >$OUTPUT

ln -sf "$MONTH/$DAY.json" public/today.json

echo $OUTPUT

