#!/bin/bash


## Load text color settings
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/tput.sh)

## Grabbing information
username=$1
password=$2
qbport=$3
port=$4
cache=$5
publicip=$(curl https://ipinfo.io/ip)

## Check input argument

if [ -z "$5" ]
  then
    warn_1; echo "Please fill in all 5 arguments accordingly: <Username> <Password> <WebUI Port> <Port used for incoming connections> <Cache Size(unit:MiB)>"; normal_4
    exit
fi

re='^[0-9]+$'
if ! [[ $3 =~ $re ]] ; then
   warn_1; echo "WebUI Port has to be an integer"; normal_4
   exit 1
fi

if ! [[ $4 =~ $re ]] ; then
   warn_1; echo "Port used for incoming connections has to be an integer"; normal_4
   exit 1
fi

if ! [[ $5 =~ $re ]] ; then
   warn_1; echo "Cache Size has to be an integer"; normal_4
   exit 1
fi

# Load Functions
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qBittorrent_install.sh)

# Define qBittorrent Setting
function qbittorrent_setting {
    mkdir -p $HOME/.config/qBittorrent
    mkdir -p $HOME/qbittorrent/Downloads/
    touch $HOME/.config/qBittorrent/qBittorrent.conf
    if [[ "${version}" =~ "4.1." ]]; then
        md5password=$(echo -n $password | md5sum | awk '{print $1}')
        cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=$port
Downloads\DiskWriteCacheSize=$cache
Downloads\SavePath=$HOME/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=$qbport
WebUI\Username=$username
EOF
    elif [[ "${version}" =~ "4.2."|"4.3." ]]; then
        wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x $HOME/qb_password_gen
        PBKDF2password=$($HOME/qb_password_gen $password)
        cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=$port
Downloads\DiskWriteCacheSize=$cache
Downloads\SavePath=$HOME/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$qbport
WebUI\Username=$username
EOF
        rm $HOME/qb_password_gen
    fi
}

# qBittorrent Download
cd $HOME
qBittorrent_download
mkdir -p $HOME/bin
test -e $HOME/bin/qbittorrent-nox && rm $HOME/bin/qbittorrent-nox
mv $HOME/qbittorrent-nox $HOME/bin/qbittorrent-nox

# qBittorrent Install
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

# qBittorrent local user service
if [ "${e}" == "0" ]; then
    qbittorrent_setting
    mkdir -p $HOME/.config/systemd/user/
    touch $HOME/.config/systemd/user/qbittorrent-nox.service
    cat <<EOF> $HOME/.config/systemd/user/qbittorrent-nox.service
[Unit]
Description=qbittorrent-nox
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
    systemctl --user enable qbittorrent-nox.service
    systemctl --user start qbittorrent-nox
# Screen
elif [ "${e}" == "1" ]; then
    qbittorrent_setting
    screen -dmS qBittorrent-nox $HOME/bin/qbittorrent-nox
    # Automatic Restart
    touch $HOME/.qBittorrent-restart.sh
    cat <<'EOF'> $HOME/.qBittorrent-restart.sh
#!/bin/bash

[[ $(pgrep -f 'qbittorrent-nox') ]] || screen -dmS qBittorrent-nox $HOME/bin/qbittorrent-nox
EOF
    chmod +x $HOME/.qBittorrent-restart.sh
    crontab -l | { cat; echo "*/1 * * * * $HOME/.qBittorrent-restart.sh"; } | crontab -

# Daemon
elif [ "${e}" == "2" ]; then
    qbittorrent_setting
    $HOME/bin/qbittorrent-nox -d
    # Automatic Restart
    touch $HOME/.qBittorrent-restart.sh
    cat <<'EOF'> $HOME/.qBittorrent-restart.sh
#!/bin/bash

[[ $(pgrep -f 'qbittorrent-nox') ]] || $HOME/bin/qbittorrent-nox -d
EOF
    chmod +x $HOME/.qBittorrent-restart.sh
    crontab -l | { cat; echo "*/1 * * * * $HOME/.qBittorrent-restart.sh"; } | crontab -
fi

if [ ! $? -eq 0 ]; then
    tput setaf 1; echo "qBittorrent installation failed, try another method"
    rm $HOME/bin/qbittorrent-nox
    rm -r $HOME/.config/qBittorrent
    exit 1
fi

# autoremove-torrents
Decision2 qBittorrent
if [ "${e}" == "0" ]; then
    tput setaf 2
    read -p "Enter desired reserved storage (in GiB): " diskspace
    read -p "Enter desired minimum seedtime (in Second): " seedtime
    tput setaf 2; echo "How to install autoremove-torrents:"
    options=("pip" "python3")
    select opt in "${options[@]}"
    do
        case $opt in
            "pip")
                e=0; break
                ;;
            "python3")
                e=1; break
                ;;
            *) tput setaf 1; echo "Please choose a valid version";;
        esac
    done
    if [ "${e}" == "0" ]; then
        pip install autoremove-torrents
    elif [ "${e}" == "1" ]; then
        git clone https://github.com/jerrymakesjelly/autoremove-torrents.git
        cd autoremove-torrents
        python3 setup.py install --prefix $HOME/.local/
        cd $HOME && rm -r autoremove-torrents
    fi
    if [ ! $? -eq 0 ]; then
        tput setaf 1; echo "autoremove-torrents installation failed"
        rm $HOME/.local/bin/autoremove-torrents
        exit 1
    fi
    touch $HOME/.config.yml
    cat << EOF >>$HOME/.config.yml
General-qb:          
  client: qbittorrent
  host: http://127.0.0.1:$qbport
  username: $username
  password: $password
  strategies:
    Upload:
      status:
        - Uploading
      remove: upload_speed < 1024 and seeding_time > $seedtime
    Disk:
      free_space:
        min: $diskspace
        path: $HOME/
        action: remove-old-seeds
  delete_data: true
M-Team-qb:          
  client: qbittorrent
  host: http://127.0.0.1:$qbport
  username: $username
  password: $password
  strategies:
    Ratio:
      trackers:
        - tracker.m-team.cc
      upload_ratio: 3
  delete_data: true
EOF
    sed -i 's+127.0.0.1: +127.0.0.1:+g' $HOME/.config.yml
    mkdir $HOME/.autoremove-torrents
    touch $HOME/.autoremove.sh
    cat << EOF >$HOME/.autoremove.sh
#!/bin/sh

while true; do
  $HOME/.local/bin/autoremove-torrents --conf=$HOME/.config.yml --log=$HOME/.autoremove-torrents
  sleep 5
done
EOF
    chmod +x $HOME/.autoremove.sh
    screen -dmS autoremove-torrents $HOME/.autoremove.sh
fi


# Cleanup
rm $HOME/.seedbox_installation.sh
clear
echo "qBittorrent $version is successfully installed, visit at $publicip:$qbport"
echo "Username is $username, Password is $password"
