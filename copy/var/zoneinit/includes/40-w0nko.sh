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
chmod -R 400 ${cert_dir}
chown -R ircd:ircd ${cert_dir}

# Move original config file back
mv /root/ircd.conf.orig /opt/local/etc/ircd/

# Enable service
svcadm enable svc:/network/w0nko:default
