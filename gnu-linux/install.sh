#!/bin/sh
#
# Installation script for Pombo.
#

if [ $(id -ru) -ne 0 ]; then
	echo "! You need to have root rights !"
	su root -c $0
	exit 0
fi

echo "\nInstalling (verbose) ..."
[ -f /etc/pombo.conf ] && mv -fv /etc/pombo.conf /etc/pombo.conf.old
install -v pombo.conf /etc
chmod 600 -v /etc/pombo.conf
install -v pombo.py /usr/local/bin/pombo
chmod +x -v /usr/local/bin/pombo
if test -f /etc/crontab ; then
	if [ $(grep -c "/usr/local/bin/pombo" /etc/crontab) != 0 ] ; then
		echo "« sed -i '/usr/local/bin/pombo/d' /etc/crontab »"
		sed -i '\/usr\/local\/bin\/pombo/d' /etc/crontab
	fi
fi
echo "« */15 * * * * root /usr/local/bin/pombo >>/etc/cron.d/pombo »"
echo "*/15 * * * * root /usr/local/bin/pombo" >>/etc/cron.d/pombo
[ -f /var/local/pombo ] && rm -fv /var/local/pombo
echo "Done."

echo "\nChecking dependancies ..."
ok=1
for package in python gpg ifconfig iwlist traceroute scrot streamer; do
	test=$(which ${package})
	[ $? != 0 ] && echo " ! ${package} needed but not installed." && ok=0
done
python check-imports.py
[ $? != 0 ] && ok=0
case ${ok} in
	1) echo "Done." ;;
	*) echo "Please install necessary tools before continuing." ;;
esac

cat <<EOM

Thank you to use Pombo!
Then you will need to:
	1 - import your GnuPG keyID
	2 - tune options into /etc/pombo.conf (you can use the GUI: pombo-config)
	3 - tune variables into pombo.php
	4 - copy pombo.php to your server(s) (both PHP versions 4 & 5 supported)
And do not forget to write somewhere in security your computer Serial Number.

EOM
exit 0
