#!/usr/bin/env bash
set -e -x

HOSTNAME_PREFIX=${hostname}
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo $HOSTNAME_PREFIX'-'$INSTANCE_ID > /etc/hostname
hostname -F /etc/hostname
sed -i -e '/^127.0.1.1/d' /etc/hosts
echo '127.0.1.1 '$HOSTNAME_PREFIX'-'$INSTANCE_ID >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive