#!/bin/sh

prefix=PUBLIC_COMPANY_

psql -Axc 'SELECT * FROM acct.get_company_data();' \
	| while IFS='|' read -r key value; do
		key=$(echo $key | tr '[:lower:]' '[:upper:]')

		echo "export $prefix$key='$value'"
	done >.env
