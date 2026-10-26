#!/usr/bin/env bash
# health.sh: check that the deployed server actually works.
#
#   ./health.sh
#
# Logs in, uploads a small file, downloads it back, and checks it matches.
# Prints OK and exits 0 if healthy. Prints FAIL and exits 1 if not.
cd "$(dirname "$0")"
source pipeline.conf

URL="ftp://$FTP_USER:$FTP_PASS@$HOST:$PORT"
SENT="health check $(date)"

if ! echo "$SENT" | curl --silent --show-error -T - "$URL/health.txt"; then
  echo "health: FAIL, could not log in and upload"
  exit 1
fi

if ! GOT=$(curl --silent --show-error "$URL/health.txt"); then
  echo "health: FAIL, could not download the file back"
  exit 1
fi

if [ "$GOT" != "$SENT" ]; then
  echo "health: FAIL, the file that came back is different"
  exit 1
fi

curl --silent --quote "DELE health.txt" "$URL/" > /dev/null   # clean up the test file
echo "health: OK, $(cat "$DEPLOY/current") is serving on $HOST:$PORT"
