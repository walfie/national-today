#!/bin/bash

set -euox pipefail

INPUT=$(mktemp)

cleanup() {
  rm "$INPUT"
}

trap cleanup EXIT

curl 'https://nationaltoday.com/what-is-today/' >$INPUT

MONTH=$(pup '.ntdb-holiday-day text{}' <$INPUT | tr '[:upper:]' '[:lower:]' | head -n 1)
DAY="$(pup '.ntdb-holiday-date text{}' <$INPUT | head -n 1)"

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

