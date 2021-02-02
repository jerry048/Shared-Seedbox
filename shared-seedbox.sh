#!/bin/bash

# Downloading Components
curl -s -O https://$tokens@raw.githubusercontent.com/jerry048/Seedbox-Install-Components/main/.seedbox_installation.sh
source .seedbox_installation.sh


## Grabing information
tokens=$1
username=$2
password=$3

# qBittorrent download
cd $HOME
qBittorrent_version
mkdir -p $HOME/bin
mv $HOME/qbittorrent-nox $HOME/bin/qbittorrent-nox

# qBittorrent local user servive
mkdir -p $HOME/.config/systemd/user/
touch $HOME/.config/systemd/user/qbittorrent.service
cat <<EOF> $HOME/.config/systemd/user/qbittorrent.service
[Unit]
Description=qbittorrent
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=exec
ExecStart=%h/bin/qbittorrent-nox
Restart=on-failure
SyslogIdentifier=qbittorrent-nox

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now qbittorrent.service

# qBittorrent Config
mkdir -p $HOME/.config/qBittorrent
touch $HOME/.config/qBittorrent/qBittorrent.conf
if [[ "${version}" =~ "4.1." ]]; then
    md5password=$(echo -n $password | md5sum | awk '{print $1}')
    cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=45000
Downloads\SavePath=$HOME/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=8080
WebUI\Username=$username
EOF
elif [[ "${version}" =~ "4.2."|"4.3." ]]; then
    curl -s -O https://$tokens@raw.githubusercontent.com/jerry048/Seedbox-Install-Components/main/qb_password_gen && chmod +x $HOME/qb_password_gen
    PBKDF2password=$($HOME/qb_password_gen $password)
    cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=45000
Downloads\SavePath=$HOME/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=8080
WebUI\Username=$username
EOF
fi
systemctl --user start qbittorrent

# Cleanup
rm $HOME/.seedbox_installation.sh
rm $HOME/qb_password_gen

echo "qBittorrent $version is sucessfully installed"