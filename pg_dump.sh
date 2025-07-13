#!/bin/bash

docker run --rm \
  -i \
  --network host \
  -e PGPASSWORD=$DB_PASSWORD \
  -e PGPORT=$DB_PORT \
  postgres:16.1-alpine \
  pg_dump "$@"
