FROM debian:latest

RUN apt-get update && apt-get install --no-install-recommends -y systemd-sysv && rm -rf /var/lib/apt/lists/* && apt clean

COPY files/ /

RUN systemctl enable containerinit

STOPSIGNAL SIGRTMIN+5

CMD ["/usr/sbin/init"]
