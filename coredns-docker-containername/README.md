# coredns-docker-containername

A CoreDNS-based DNS server that automatically resolves Docker container names to their respective IP addresses. This is especially useful when running Docker in a routed network setup.

## Features

- **Automated Docker DNS:** Resolves container names automatically.
- **Extra Zone Support:** Load custom zone files from a specified mount point.
- **Container Labeling:** Use the `dns_name` label on other containers to define custom DNS names.
- **Flexible DNS Modes:** Supported modes via labels or extra data:
  - `static`: Creates a standard `A` record pointing to the target IP.
  - `forwarded`: Treats the target container as a DNS server and forwards queries to it (allows infinite chaining).

---

## Configuration

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `DNS_CORE_ZONE_NAME` | The primary domain zone managed by this container. |
| `DNS_CORE_EXTRA_DATA` | Multi-line string to define explicit static or forwarded records. |

### Docker Labels

You can configure other containers to be recognized by this DNS server using these labels:
- `dns_name`: The desired domain name for the container.
- `dns_mode`: Set to `static` or `forwarded`.

---

## Volume Mounts

- `/var/run/docker.sock`: Required to listen to Docker events and read container metadata.
- `/dns/zones/dynamic/static` (Optional): Mount your custom external zone files here.

## Usage

### Docker Compose Example

Create a `docker-compose.yml` file with the following configuration:

```yaml
services:
  dns:
    image: lxeu/coredns-docker-containername
    restart: unless-stopped
    environment:
      - DNS_CORE_ZONE_NAME=srv.intra.net
      - |
          DNS_CORE_EXTRA_DATA="
          static		srv.intra.net.		10.0.0.5
          static		vpn				192.168.77.9
          forwarded		sub				192.168.45.1
          "
    ports:
      - 53:53/udp
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      # Place your static configurations here
      - ./data/zones:/dns/zones/dynamic/static
```

Run the container:
```bash
docker compose up -d
```

---

### Zone File Format Example
$ORIGIN iot.intra.net.
$TTL 3600
@   IN  SOA ns1.iot.intra.net. admin.iot.intra.net. (
        16571 ; serial
        3600       ; refresh
        1800       ; retry
        1209600    ; expire
        3600 )     ; minimum

house.wattmeter	IN A 192.168.5.8
garage.wattmeter	IN A 192.168.5.15
```
Test:
```bash
$ ping house.wattmeter.iot.intra.net
PING house.wattmeter.iot.intra.net (192.168.5.8) 56(84) bytes of data.
64 bytes from 192.168.5.8: icmp_seq=1 ttl=63 time=0.101 ms
^C
```

### Example: Use as root DNS server and forward zones to respecive servers




# TODO
also mention:
- if you don't mount docker it server static configuration (mounted zone files) and $DNS_CORE_EXTRA_DATA
- you can leave $DNS_CORE_ZONE_NAME , in this case only static zone files will be served

example usages:
- serve docker names (only mounting docker socket and set DNS_CORE_ZONE_NAME)
- act as forward base (dont mount docker socket and zone files and only fill DNS_CORE_ZONE_NAME DNS_CORE_EXTRA_DATA with ips you want to forward)
- server static zones (unset DNS_CORE_ZONE_NAME and not mount docker socket)
