#!/bin/sh
set -eo pipefail
[ "${DEBUG}" == 'true' ] && set -x

LOCUST_BIN='/usr/bin/locust'
LOCUST_SCRIPT="${LOCUST_SCRIPT:-/locust-tasks/tasks.py}"
LOCUST_MODE="${LOCUST_MODE:-standalone}"
LOCUST_OPTS="${LOCUST_OPTS:-}"

WAIT_FOR_TARGET="${WAIT_FOR_TARGET:-true}"
WAIT_FOR_ENDPOINT="${WAIT_FOR_ENDPOINT:-/health}"
WAIT_FOR_HTTP_CODE="${WAIT_FOR_HTTP_CODE:-200}"
WAIT_FOR_SLEEP_TIME="${WAIT_FOR_SLEEP_TIME:-5}"
WAIT_FOR_CURL_CMD="${WAIT_FOR_CURL_CMD:-curl -s -o /dev/null --max-time 1 -w %{http_code}}"

TARGET_HOST="${TARGET_HOST:?Required variable not set}"

# Wait for target service to become reachable from within the locust pod before starting the test
CODE='null'
if [ "${WAIT_FOR_TARGET}" == 'true' ]; then
  echo "Waiting for http return code ${WAIT_FOR_HTTP_CODE} from ${TARGET_HOST}${WAIT_FOR_ENDPOINT}"
  while [ "${CODE}" != "${WAIT_FOR_HTTP_CODE}" ]; do
    CODE="$(${WAIT_FOR_CURL_CMD} "${TARGET_HOST}${WAIT_FOR_ENDPOINT}" || true)"
    echo "Return code from ${TARGET_HOST}${WAIT_FOR_ENDPOINT} is ${CODE}"
    # Sleep only if we're not done yet
    [ "${CODE}" != "${WAIT_FOR_HTTP_CODE}" ] && sleep "${WAIT_FOR_SLEEP_TIME}"
  done
fi

if [ "$LOCUST_MODE" == 'master' ]; then
  LOCUST_CMD="${LOCUST_BIN} -f ${LOCUST_SCRIPT} --host ${TARGET_HOST} --master ${LOCUST_OPTS}"
elif [ "$LOCUST_MODE" == 'worker' ]; then
  LOCUST_MASTER="${LOCUST_MASTER:?Required variable not set}"
  LOCUST_CMD="${LOCUST_BIN} -f ${LOCUST_SCRIPT} --host ${TARGET_HOST} --slave --master-host=${LOCUST_MASTER} ${LOCUST_OPTS}"
    
  # Wait for master
  while ! wget --spider -qT5 "${LOCUST_MASTER}:${LOCUST_MASTER_WEB}" >/dev/null 2>&1; do
    echo 'Waiting for master...'
    sleep 5
  done
else
  LOCUST_CMD="${LOCUST_BIN} -f ${LOCUST_SCRIPT} --host ${TARGET_HOST} ${LOCUST_OPTS}"
fi

echo "Executing locust command: ${LOCUST_CMD}"
exec ${LOCUST_CMD}
