#!/bin/bash
set -e

if [ -z "`ls /usr/local/etc/php/conf.d`" ] 
then
	cp -R /etc-start/php/conf.d/* /usr/local/etc/php/conf.d
fi


# set ID docker run
agid=${agid:-$auid}
auser=${auser:-www-data}

if [[ -z "${auid}" ]]; then
  echo "start"
elif [[ "$auid" = "0" ]] || [[ "$aguid" == "0" ]]; then
	echo "run in user root"
	export auser=root
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	sed -i -e "/^user = .*/cuser = $auser" /usr/local/etc/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /usr/local/etc/php-fpm.conf
else
if id $auser >/dev/null 2>&1; then
        echo "user exists"
	sed -i -e "/^user = .*/cuser = $auser" /usr/local/etc/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /usr/local/etc/php-fpm.conf
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	# usermod alpine
		#deluser $auser && delgroup $auser
		#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# usermod ubuntu/debian
		usermod -u $auid $auser
		groupmod -g $agid $auser
else
        echo "user does not exist"
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	# create user alpine
	#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# create user ubuntu/debian
	groupadd -g $agid $auser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $auser $auser
	sed -i -e "/^user = .*/cuser = $auser" /usr/local/etc/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /usr/local/etc/php-fpm.conf
fi

fi

exec "$@"
