#!/bin/bash
meltano install extractor tap-oracle
meltano install loader target-postgres
exec "$@"
