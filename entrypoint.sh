#!/bin/sh
set -eo pipefail

LOCUST_BIN='/usr/bin/locust'
LOCUST_SCRIPT="${LOCUST_SCRIPT:-/locust-tasks/tasks.py}"
LOCUST_MODE="${LOCUST_MODE:-standalone}"
LOCUST_OPTS="${LOCUST_OPTS:-}"

TARGET_HOST="${TARGET_HOST:?Required variable not set}"

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
