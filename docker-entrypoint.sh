#!/bin/bash
set -e
echo "NNTmux DB: ${NEWZNAB_DB_HOST}"
echo "NNTmux DB PORT: ${NEWZNAB_DB_PORT}"
echo "NNTmux Manticore Host: ${NEWZNAB_MANTICORE_HOST}"
echo "NNTmux Manticore Port: ${NEWZNAB_MANTICORE_PORT}"

## Do some install stuff on first run
if [ "$1" == "init" -a ! -f run_once ]; then
	## Deploy the artisan nntmux bit
	cd /var/www/NNTmux/
	## Script to automate the artisan nntp-tmux:install process
	./nntp_init
	## Do inits that require a live env
	SPINXSEARCH_DIR=/var/www/NNTmux/misc/sphinxsearch/
	cd ${SPINXSEARCH_DIR}
	php create_se_tables.php ${NEWZNAB_MANTICORE_HOST} ${NEWZNAB_MANTICORE_PORT} # db is a reference to the database associated with this container
	php populate_rt_indexes.php releases_rt
	php populate_rt_indexes.php predb_rt
	## Kick these services again
	service nginx restart
	service php7.2-fpm restart
	service manticore restart
	touch run_once
fi
## Clear the application cache
cd /var/www/NNTmux/
php artisan cache:clear

# Hold forever
exec tail -f /dev/null
