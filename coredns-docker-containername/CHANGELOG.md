1.1.0:
	- dns_mode.delegated renamed to dns_mode.forwarded to align to proper technical solution.
	- Multiple configurration mode:
		- DNS_CORE_EXTRA_DATA envvar: inject extra data like coming from containers
			It can be used to add static entries and forwards to dynamic structure.
		- if docker socket not mounted: serve only static config.
		- DNS_CORE_ZONE_NAME envvar: if empty, serving only static zone files mounted under /dns/zones/dynamic/static

1.0.0:
	- Initial version: serve docker container IP with containers name.
	- Additional docker label "dns_names" served as well.
	- Two mode set by docker label "dns_mode"
		- "static" (default): serve as A record container name + dns_names => IP
		- delegated: (*.\.)?${container_name} forwarded to => ${IP}:53 makes infinite DNS chaining possible
