#!/bin/bash

source /containerinit/env

IFS=, read -a REQ_INSTALL <<< "$LXE_INSTALL"

# check if $1 is requested and ${2:-$1} command not exists yet
chkreq()
{
    [[ " ${REQ_INSTALL[*]} " =~ " ${1} " ]] && ! command -v ${2:-$1} > /dev/null 2>&1
}

if [ ! -z "$LXE_INSTALL" ] || [ ! -z "$LXE_INSTALL_APT" ]
then
    apt-get update
fi

pkginst()
{
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

if chkreq base asdadw3fhgywa
then
	pkginst socat curl gettext-base \
    nmap bwm-ng htop links2 screen git nano\
    mc hexedit lsof sudo socat nethogs iotop zip iftop  wget tree\
    rsync mailutils dnsutils tmux curl netcat-openbsd net-tools stress \
	gpg lsb-release jq iputils-ping ca-certificates iproute2
fi

if chkreq ssh sshd
then
	pkginst sshfs ssh
	echo "UseDNS no\nKerberosAuthentication no\nGSSAPIAuthentication no\nPermitRootLogin yes\n" >> /etc/ssh/sshd_config
	systemctl enable --now ssh
fi

if chkreq python
then
    pkginst python3 python3-pip
fi

# Install compilers
#    apt-get install -y golang gcc cmake rustc openjdk-21-jdk maven npm nodejs 

if chkreq docker
then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    pkginst docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now containerd docker
fi

if chkreq helm
then
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
	apt-get update
	pkginst helm
fi

if chkreq terraform
then
	wget -O- https://apt.releases.hashicorp.com/gpg | \
		gpg --dearmor | \
		tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
	cat /etc/apt/sources.list.d/hashicorp.list && apt-get update
	pkginst terraform
fi

if chkreq ansible
then
    pkginst ansible sshpass
	ansible-galaxy collection install community.general
fi

if chkreq kubectl
then
    cd /bin && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod 755 kubectl
fi

# TODO
if chkreq xrdp
then
    pkginst systemd xrdp xserver-xorg dbus-x11
    systemctl enable --now xrdp dbus
fi

if chkreq xfce xfce4-session
then
    pkginst xfce4 xfce4-goodies
fi

# TODO
if chkreq flatpak
then
    pkginst flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# TODO
if chkreq snap
then
    pkginst snap snapd
    systemctl enable --now snapd
fi

if [ ! -z "$LXE_INSTALL_APT" ]
then
    IFS=, read -a PKG <<< "$LXE_INSTALL_APT"
    pkginst "${PKG[@]}"
fi

