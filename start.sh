#!/bin/sh
set -e

nohup php-fpm &

exec nginx
