# Configure w0nko based on mdata information

# SSL
host=$(mdata-get sdc:hostname)
cert_dir='/var/ircd/'

# SSL configuration
if mdata-get ircd_ssl 1>/dev/null 2>&1; then
	mdata-get ircd_ssl > ${cert_dir}ircd.pem
else
	openssl req -newkey rsa:2048 -keyout ${cert_dir}ircd.key \
	            -out ${cert_dir}ircd.csr -nodes \
	            -subj "/C=DE/L=Raindbow City/O=Aperture Science/OU=Please use valid ssl certificate/CN=${host}"
	openssl x509 -in ${cert_dir}ircd.csr -out ${cert_dir}ircd.crt -req -signkey ${cert_dir}ircd.key -days 128
	cat ${cert_dir}ircd.crt ${cert_dir}ircd.key > ${cert_dir}ircd.pem
fi

# Modify motd to be located at the delegate dataset
touch /opt/local/etc/ircd/ircd.motd
ln -s /opt/local/etc/ircd/ircd.motd /var/ircd/ircd.motd

# Fix all permissions
chown -R ircd:ircd ${cert_dir}

# Modify original config file and copy it to ircd.conf if not exists
if [ ! -e /opt/local/etc/ircd/ircd.conf ]; then
	# Create config based on the minimal template
	network=$(mdata-get ircd_network 2>/dev/null || echo 'Example')
	description=$(mdata-get ircd_description 2>/dev/null || echo 'Awesome Example Network')
	# Network workaround
	nics=$(mdata-get sdc:nics)
	if [[ ${nics} =~ "dhcp" ]]; then
		ipv4=$(ifconfig net0 | grep inet | awk '{ print $2 }')
		ipv6='%IPv6%'
	else
		ipv4=$(echo ${nics} | json 0.ip | sed 's:/.*::g')
		ipv6=$(echo ${nics} | json 1.ip | sed 's:/.*::g')
	fi

	sed -e "s:%FQDN%:${host}:g" \
		-e "s:%DESCRIPTION%:${description}:g" \
		-e "s:%IPv4%:${ipv4}:g" \
		-e "s:%IPv6%:${ipv6}:g" \
		-e "s:%NETWORK%:${network}:g" \
		/var/ircd/ircd.conf.minimal > /opt/local/etc/ircd/ircd.conf
fi

# Enable service
svcadm enable svc:/network/w0nko:default
