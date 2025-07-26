#!/bin/bash

echo "=== Environment Variable Test ===" >&2
echo "MYSQL_HOST: '${MYSQL_HOST}'" >&2
echo "MYSQL_PORT: '${MYSQL_PORT}'" >&2
echo "MYSQL_USER: '${MYSQL_USER}'" >&2
echo "MYSQL_PASSWORD: '${MYSQL_PASSWORD}'" >&2
echo "MYSQL_DATABASE: '${MYSQL_DATABASE}'" >&2
echo "=================================" >&2

if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
    echo "ERROR: Required environment variables are missing!" >&2
    exit 1
else
    echo "SUCCESS: All required environment variables are set!" >&2
    exit 0
fi
