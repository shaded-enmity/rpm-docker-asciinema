#!/bin/bash

_port=${REDIS_PORT:-6379}
_db=/var/lib/redis/

redis-server --port ${_port} --dir ${_db}
