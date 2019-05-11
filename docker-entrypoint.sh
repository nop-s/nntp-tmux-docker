#!/bin/bash
set -e
echo "NNTmux DB: ${DB_HOST}"
echo "NNTmux DB PORT: ${DB_PORT}"
echo "NNTmux Manticore Host: ${MANTICORE_HOST}"
echo "NNTmux Manticore Port: ${MANTICORE_PORT}"

## Do some install stuff on first run
if [ "$1" == "init" -a ! -f run_once ]; then
	## Deploy the artisan nntmux bit
	cd /var/www/NNTmux/
	## Script to automate the artisan nntp-tmux:install process
	./nntp_init
	## Do inits that require a live env
	SPINXSEARCH_DIR=/var/www/NNTmux/misc/sphinxsearch/
	cd ${SPINXSEARCH_DIR}
	php create_se_tables.php ${MANTICORE_HOST} ${MANTICORE_PORT} # db is a reference to the database associated with this container
	php populate_rt_indexes.php releases_rt
	php populate_rt_indexes.php predb_rt
	## Kick these services again
	touch run_once
fi

## Clear the application cache
cd /var/www/NNTmux/
php artisan cache:clear

## Kick off the services just in case
service nginx restart
service php7.2-fpm restart
service manticore restart

# Hold forever
exec tail -f /dev/null
