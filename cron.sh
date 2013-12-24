#!/bin/bash

# Pull out download numbers, then rotate all logs into manta.

set -e

export MANTA_KEY_ID=55:5e:9a:bc:42:59:df:cb:ad:00:54:f6:59:53:20:83
export MANTA_USER=isaacs
export MANTA_URL=https://us-east.manta.joyent.com

base="$(svcs -L npm-lylog)"
for log in $base $base.*; do
  file="$(basename $log)"
  file="${file//:/_}"
  cp "$log" "$file"
  echo -n "" > "$log"
  node upload.js "$file"

  gzfile="${file}.gz"
  gzip -9 <$file >$gzfile
  d=$(date '+%Y-%m-%d')
  mput -f $gzfile /isaacs/stor/npm-registry-logs/$d.$gzfile
  rm -f $gzfile
  rm $file
  if ! [ "$log" == "$base" ]; then
    rm $log
  fi
done
