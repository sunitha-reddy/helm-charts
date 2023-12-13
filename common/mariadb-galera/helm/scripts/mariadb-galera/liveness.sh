#!/usr/bin/env bash
set +e
set -u
set -o pipefail

source /opt/${SOFTWARE_NAME}/bin/common-functions.sh

function checkdblogon {
  mysql --protocol=socket --user=root --batch --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.database }} --execute="SHOW DATABASES;" | grep --silent 'mysql'
  if [ $? -eq 0 ]; then
    echo 'MariaDB MySQL API reachable'
  else
    echo 'MariaDB MySQL API not reachable'
    exit 1
  fi
}

function checkgaleraport {
  timeout {{ $.Values.livenessProbe.timeoutSeconds.database }} bash -c "</dev/tcp/${CONTAINER_IP}/${GALERA_PORT}"
  if [ $? -eq 0 ]; then
    echo 'MariaDB Galera API reachable'
  else
    echo 'MariaDB Galera API not reachable'
    exit 1
  fi
}

checkdblogon
checkgaleraport
setconfigmap "running" "true" "Update"