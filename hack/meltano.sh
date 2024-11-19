#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <table_name>"
  exit 1
fi

TABLE_NAME=$1

echo "Installing general dependencies..."
meltano install extractor tap-oracle
meltano install loader target-postgres

echo "Installing extractor for table: $TABLE_NAME..."
meltano install extractor "tap-$TABLE_NAME"

echo "Running EL for table: $TABLE_NAME..."
meltano el "tap-$TABLE_NAME" target-postgres --state-id="${TABLE_NAME}-to-postgres"

echo "ETL process completed for table: $TABLE_NAME"