#!/bin/sh

# https://wiki.archlinux.org/title/Nginx#Warning:_Could_not_build_optimal_types_hash
sed -i '/^http {$/a\
    types_hash_max_size 4096;\n    server_names_hash_bucket_size 128;\n' \
		/etc/nginx/nginx.conf
