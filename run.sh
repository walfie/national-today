#!/bin/bash

set -euox pipefail

INPUT=$(mktemp)

cleanup() {
  rm "$INPUT"
}

trap cleanup EXIT

curl 'https://nationaltoday.com/what-is-today/' >$INPUT

OUTPUT=$(
  pup '.ntdb-holiday-day, .ntdb-holiday-date text{}' <$INPUT \
    | uniq \
    | tr '[:upper:]' '[:lower:]' \
    | tr '\n' '/' \
    | sed 's|/$|.json|' \
)

mkdir -p $(dirname $OUTPUT)

pup '.title-box > :not(.holiday-date) json{}' <$INPUT \
  | jq 'map(.children | { title: .[0].children[0].text, description: .[1].text })' >$OUTPUT

echo $OUTPUT

