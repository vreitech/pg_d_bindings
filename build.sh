#!/bin/bash

cd "$(realpath "$(dirname "$0")")"

# Builds the extension
ldc2 -betterC -shared -relocation-model=pic pg_d/abi.d pg_d/fmgr.d pg_d/mem.d pg_d/pgtext.d pg_d/srf.d pg_d/pgmagic.d extension_example.d -of=extension_example.so

# Copying files to apropriate places
sudo cp extension_example.control /usr/pgsql-18/share/extension/
sudo cp extension_example--1.0.sql /usr/pgsql-18/share/extension/
sudo cp extension_example.so /usr/pgsql-18/lib/

echo "Extension copied to /usr/pgsql-18/"
echo "Use 'CREATE EXTENSION' command in apropriate database, for example:"
echo "  sudo -u postgres psql -d postgres -c 'CREATE EXTENSION extension_example;'"