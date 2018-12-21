#!/bin/bash

set_logs() {

mkdir -p ${SCRIPT_PATH}/logs

main_log="${SCRIPT_PATH}/logs/main.log"
err_log="${SCRIPT_PATH}/logs/error.log"
failed_checks_log="${SCRIPT_PATH}/logs/failed_checks.log"
make_log="${SCRIPT_PATH}/logs/make.log"
make_err_log="${SCRIPT_PATH}/logs/make_error.log"

}
