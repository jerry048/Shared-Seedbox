#!/bin/bash

## Grabing information
tokens=$1
username=$2
password=$3

# Downloading Components
curl -s -O https://$tokens@raw.githubusercontent.com/jerry048/Seedbox-Install-Components/main/.seedbox_installation.sh
source .seedbox_installation.sh

# Define qBittorrent Config
function qbittorrent_config {
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
}

# qBittorrent download
cd $HOME
qBittorrent_version
mkdir -p $HOME/bin
mv $HOME/qbittorrent-nox $HOME/bin/qbittorrent-nox

# qBittorrent install
tput setaf 2; echo "How to install qBittorrent:"
options=("Local user service" "Screen" "Daemon")
select opt in "${options[@]}"
do
    case $opt in
        "Local user service")
            e=0; break
            ;;
        "Screen")
            e=1; break
            ;;
        "Daemon")
            e=2; break
            ;;
        *) tput setaf 1; echo "Please choose a valid version";;
    esac
done


# qBittorrent local user servive
if [ "${e}" == "0" ]; then
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
    qbittorrent_config
    systemctl --user start qbittorrent
# Screen
elif [ "${e}" == "1" ]; then
screen -dmS qBittorrent-nox $HOME/bin/qbittorrent-nox
# Daemon
elif [ "${e}" == "2" ]; then
$HOME/bin/qbittorrent-nox -d
fi

# Cleanup
rm $HOME/.seedbox_installation.sh
rm $HOME/qb_password_gen

echo "qBittorrent $version is sucessfully installed"