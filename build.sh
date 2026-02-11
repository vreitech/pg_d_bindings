#!/bin/bash

ldc2 -betterC -shared -relocation-model=pic pg_d/abi.d pg_d/fmgr.d pg_d/mem.d pg_d/pgtext.d pg_d/srf.d pg_d/pgmagic.d extension_example.d -of=extension_example.so
