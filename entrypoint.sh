#!/bin/sh
set -e
set -xv

cd /var/www/html

if [ -z "$(ls)" ]
then
    echo "unpacking pagekit archive"
    unzip -q /opt/pagekit.zip
    rm /opt/pagekit.zip
    chown -R www-data:www-data .
    chmod -R g+w .
    chmod +x pagekit
fi

if [ ! -f config.php ]
then
    if [ -n "$PAGEKIT_USERNAME$PAGEKIT_PASSWORD$PAGEKIT_TITLE$PAGEKIT_MAIL$PAGEKIT_DB_DRIVER$PAGEKIT_DB_PREFIX$PAGEKIT_DB_HOST$PAGEKIT_DB_NAME$PAGEKIT_DB_USERNAME$PAGEKIT_DB_PASSWORD$PAGEKIT_LOCALE" ]
    then
	if [ -n "$WAIT_HOSTS" ]
	then
	    echo "waiting for database host to bekome ready"
	    /usr/local/bin/wait
	fi
	
	echo "executing pagekit setup via CLI"
	./pagekit setup -vvv --no-interaction \
		  ${PAGEKIT_USERNAME:+"--username=${PAGEKIT_USERNAME}"} \
		  ${PAGEKIT_PASSWORD:+"--password=${PAGEKIT_PASSWORD}"} \
		  ${PAGEKIT_TITLE:+"--title=${PAGEKIT_TITLE}"} \
		  ${PAGEKIT_MAIL:+"--mail=${PAGEKIT_MAIL}"} \
		  ${PAGEKIT_DB_DRIVER:+"--db-driver=${PAGEKIT_DB_DRIVER}"} \
		  ${PAGEKIT_DB_PREFIX:+"--db-prefix=${PAGEKIT_DB_PREFIX}"} \
		  ${PAGEKIT_DB_HOST:+"--db-host=${PAGEKIT_DB_HOST}"} \
		  ${PAGEKIT_DB_NAME:+"--db-name=${PAGEKIT_DB_NAME}"} \
		  ${PAGEKIT_DB_USERNAME:+"--db-user=${PAGEKIT_DB_USERNAME}"} \
		  ${PAGEKIT_DB_PASSWORD:+"--db-pass=${PAGEKIT_DB_PASSWORD}"} \
		  ${PAGEKIT_LOCALE:+"--locale=${PAGEKIT_LOCALE}"}
	chown -R www-data:www-data .
    else
	echo "visit your new pagekit site to finish the setup"
    fi
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- start.sh "$@"
fi

exec "$@"
