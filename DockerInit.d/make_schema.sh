#!/bin/bash
## Hack script to generate the schema.sql so we don't have to push a password into the docker-compose build process
ENV_FILE=$1
SCRATCH_DIR=$2
echo "Env file: ${ENV_FILE}"
echo "SCRATCH DIR : ${SCRATCH_DIR}"
if [ ! -f "${ENV_FILE}" ]; then
	echo "Pass in the path to the .env file!"
	exit 1
fi

if [ ! -d "${SCRATCH_DIR}" ]; then
	echo "Destination path to save schema file required."
	exit 1
fi

## Load the environment variables into this context
source ${ENV_FILE}
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}; \
	CREATE USER IF NOT EXISTS '${DB_USERNAME}' IDENTIFIED BY '${DB_PASSWORD}'; \
GRANT ALL ON ${DB_DATABASE}.* TO '${DB_USERNAME}'@'%'; \
GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}' WITH GRANT OPTION; \
flush privileges; \
INSTALL SONAME 'ha_sphinx';" > ${SCRATCH_DIR}/schema.sql;
