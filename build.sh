#!/bin/bash

ldc2 -betterC -shared -relocation-model=pic abi.d fmgr.d mem.d text.d srf.d pgmagic.d extension_example.d -of=extension_example.so
