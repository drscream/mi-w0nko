#!/bin/bash
UUID=$(mdata-get sdc:uuid)
DDS=zones/${UUID}/data

if zfs list ${DDS} 1>/dev/null 2>&1; then
	zfs create ${DDS}/etc_ircd || true
	zfs set mountpoint=/opt/local/etc/ircd ${DDS}/etc_ircd
	chown ircd:ircd /opt/local/etc/ircd || true
fi
