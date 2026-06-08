FROM debian:latest

# install basic utils
    RUN apt-get update && apt-get install -y --no-install-recommends tini curl ca-certificates  && rm -rf /var/lib/apt/lists/* && apt clean
# install docker (source: https://docs.docker.com/engine/install/debian/#install-using-the-repository)
    RUN install -m 0755 -d /etc/apt/keyrings
    RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    RUN chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    RUN apt-get update && apt-get install --no-install-recommends -y docker-ce-cli &&  rm -rf /var/lib/apt/lists/* && apt clean

# Install coredns
    ARG COREDNS_VERSION=1.14.3
    ARG TARGETARCH=amd64

    RUN curl -sSL "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_${TARGETARCH}.tgz" | tar -xz -C /bin

COPY files/ /


ENTRYPOINT ["/usr/bin/tini", "/usr/bin/entrypoint", "--", "entrypoint"]