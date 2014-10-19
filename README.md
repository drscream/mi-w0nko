# mi-w0nko

This repository is based on [Joyent mibe](https://github.com/joyent/mibe). Please note this repository should be build with the [mi-core-base](https://github.com/skylime/mi-core-base) mibe image.

## description

Install w0nko, IRCu based, IRC server. If nothing is configured the server run
as hub. Please keep the following file / folder structure in mind, if something
went wront the server will not start:

- `/var/ircd`: Containts `ircd.motd`, `ircd.pem`, pid and log files
- `/opt/local/etc/ircd`: Contains the configuration file `ircd.conf`

The configuration file is stored in a delegate dataset.

## mdata variables

- `ircd_ssl`: SSL certificate, key and ca chain in PEM format
- `ircd_network`: Name of your network
