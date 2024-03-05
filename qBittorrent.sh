#!/bin/bash

## List of qBittorrent Version that is supported
declare -a qb_ver_list=("4.1.9" "4.1.9.1" "4.2.5" "4.3.9" "4.4.5" "4.5.5" "4.6.3")
#Generate the list of qBittorrent Version that is supported
unset qb_name_list i
for i in "${qb_ver_list[@]}"
do
	qb_name_list+=("qBittorrent-$i")
done

## List of libtorrent Version that is supported
declare -a lib_ver_list=("1_1_14" "v1.2.19" "v2.0.10")
#Generate the list of libtorrent Version that is supported
unset lib_name_list i
for i in "${lib_ver_list[@]}"
do
	lib_name_list+=("libtorrent-$i")
done

## Text colors and styles
info() {
	tput sgr0; tput setaf 2; tput bold
	echo "$1"
	tput sgr0
}
boring_text() {
	tput sgr0; tput setaf 7; tput dim
	echo "$1"
	tput sgr0
}
need_input() {
	tput sgr0; tput setaf 6 ; tput bold
	echo "$1" 1>&2
	tput sgr0
}
warn() {
	tput sgr0; tput setaf 3
	echo "$1" 1>&2
	tput sgr0
}
fail() {
	tput sgr0; tput setaf 1; tput bold
	echo "$1" 1>&2
	tput sgr0
}
fail_exit() {
	tput sgr0; tput setaf 1; tput bold
	echo "$1" 1>&2
	tput sgr0
	exit 1
}
seperator() {
	echo -e "\n"
	echo $(printf '%*s' "$(tput cols)" | tr ' ' '=')
	echo -e "\n"
}

## Grabbing information
username=$1
password=$2
qb_ver=("qBittorrent-$3")
lib_ver=("libtorrent-$4")
qb_cache=$5
qb_port=$6
qb_incoming_port=$7
publicip=$(curl https://ipinfo.io/ip)

#Check input argument
if [ -z "$username" ] || [ -z "$password" ] || [ -z "$qb_ver" ] || [ -z "$lib_ver" ] || [ -z "$qb_cache" ] || [ -z "$qb_port" ] || [ -z "$qb_incoming_port" ]; then
	fail_exit "Please enter all the required arguments"
fi
if [[ ! "$qb_cache" =~ ^[0-9]+$ ]]; then
	fail_exit "Invalid cache size"
fi
if [[ ! "$qb_port" =~ ^[0-9]+$ ]] || [[ "$qb_port" -lt 1024 ]] || [[ "$qb_port" -gt 65535 ]]; then
	fail_exit "Invalid WebUI port number"
fi
if [[ ! "$qb_incoming_port" =~ ^[0-9]+$ ]] || [[ "$qb_incoming_port" -lt 1024 ]] || [[ "$qb_incoming_port" -gt 65535 ]]; then
	fail_exit "Invalid incoming port number"
fi

# Check if the ports are occupied
if [ -x "$(command -v lsof)" ]; then
	if lsof -Pi :$qb_port -sTCP:LISTEN -t >/dev/null; then
		fail_exit "Port $qb_port is already in use"
	fi
	if lsof -Pi :$qb_incoming_port -sTCP:LISTEN -t >/dev/null; then
		fail_exit "Port $qb_incoming_port is already in use"
	fi
elif [ -x "$(command -v netstat)" ]; then
	if netstat -tuln | grep -w $qb_port; then
		fail_exit "Port $qb_port is already in use"
	fi
	if netstat -tuln | grep -w $qb_incoming_port; then
		fail_exit "Port $qb_incoming_port is already in use"
	fi
fi



qb_ver_choose(){
	need_input "Please choose your qBittorrent Version:"
	select opt in "${qb_name_list[@]}"
	do
		case $opt in
		qBittorrent*)
			qb_ver=${opt}; break
			;;
		*) warn "Please choose a valid version" ;;
		esac
	done
}

lib_ver_choose(){
	need_input "Please choose your libtorrent version:"
	select opt in "${lib_name_list[@]}"
	do
		case $opt in
		libtorrent*)
			lib_ver=${opt}; break
			;;
		*) warn "Please choose a valid version" ;;
		esac
	done
}

lib_ver_check(){
	## Check if the libtorrent version is compatible with qBittorrent version
	if [[ "${qb_ver}" =~ "4.1." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" == "libtorrent-1_1_14" ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver"
				warn "qBittorrent $qb_ver is compatible with libtorrent-1_1_x only"
				warn "Please choose a compatible version"
				lib_ver_choose
			else
				break
			fi
		done
	elif [[ "${qb_ver}" =~ "4.2." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" =~ "libtorrent-v1.2." ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver"
				warn "qBittorrent $qb_ver is compatible with libtorrent-v1.2.x only"
				warn "Please choose a compatible version"
				lib_ver_choose
			else
				break
			fi
	done
	elif [[ "${qb_ver}" =~ "4.3." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" =~ "libtorrent-v1.2." ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver"
				warn "qBittorrent $qb_ver is compatible with libtorrent-v1.2.x only"
				warn "Please choose a compatible version"
				lib_ver_choose
			else
				break
			fi
	done
	elif [[ "${qb_ver}" =~ "4.4." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" =~ "libtorrent-v1.2." ]] && [[ ! "${lib_ver}" =~ "libtorrent-v2.0." ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver";
				warn "qBittorrent $qb_ver is compatible with libtorrent-v1.2.x or libtorrent-v2.0.x only";
				warn "Please choose a compatible version";
				lib_ver_choose
			else
				break
			fi
		done
	elif [[ "${qb_ver}" =~ "4.5." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" =~ "libtorrent-v1.2." ]] && [[ ! "${lib_ver}" =~ "libtorrent-v2.0." ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver"
				warn "qBittorrent $qb_ver is compatible with libtorrent-v1.2.x or libtorrent-v2.0.x only"
				warn "Please choose a compatible version"
				lib_ver_choose
			else
				break
			fi
		done
	elif [[ "${qb_ver}" =~ "4.6." ]]; then
		while true
		do
			if [[ ! "${lib_ver}" =~ "libtorrent-v1.2." ]] && [[ ! "${lib_ver}" =~ "libtorrent-v2.0." ]]; then
				tput sgr0; clear
				warn "qBittorrent $qb_ver is not compatible with libtorrent $lib_ver"
				warn "qBittorrent $qb_ver is compatible with libtorrent-v1.2.x or libtorrent-v2.0.x only"
				warn "Please choose a compatible version"
				lib_ver_choose
			else
				break
			fi
		done
	fi
}

qb_install_check(){
	# Check if qBittorrent version and libtorrent version are supported
	## Check if the qBittorrent version is supported
	if [[ ! " ${qb_name_list[@]} " =~ " ${qb_ver} " ]]; then
		warn "qBittorrent $qb_ver is not supported"
		qb_ver_choose
	fi
	## Check if the libtorrent version is supported
	if [[ ! " ${lib_name_list[@]} " =~ " ${lib_ver} " ]]; then
		warn "libtorrent $lib_ver is not supported"
		lib_ver_check
	fi
	## Check if the libtorrent version is compatible with qBittorrent version
	lib_ver_check
}


install_qBittorrent_(){
	username=$1
	password=$2
	qb_ver=$3
	lib_ver=$4
	qb_cache=$5
	qb_port=$6
	qb_incoming_port=$7

	## Check if qBittorrent is running
	if pgrep -i -f qbittorrent; then
		warn "qBittorrent is running. Stopping it now..."
		pkill -s $(pgrep -i -f qbittorrent)
	fi
	# Check if it is still running
	if pgrep -i -f qbittorrent; then
		warn "Failed to stop qBittorrent. Please stop it manually"
		exit 1
	fi

	## Check if qbittorrent-nox is installed
	if test -e $HOME/bin/qbittorrent-nox; then
		warn "qBittorrent is already installed. Replacing it now..."
		rm $HOME/bin/qbittorrent-nox
		rm $HOME/.config/qBittorrent/qBittorrent.conf
	fi

	## Download qBittorrent-nox executable
	# Determine the CPU architecture
	if [[ $(uname -m) == "x86_64" ]]; then
		arch="x86_64"
	elif [[ $(uname -m) == "aarch64" ]]; then
		arch="ARM64"
	else
		warn "Unsupported CPU architecture"
		return 1
	fi
	wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/$arch/$qb_ver%20-%20$lib_ver/qbittorrent-nox && chmod +x $HOME/qbittorrent-nox
	#Check if the download is successful
	if [ $? -ne 0 ]; then
		warn "Failed to download qBittorrent-nox executable"
		return 1
	fi

	# Install qbittorrent-nox
	mkdir -p $HOME/bin/
	mv $HOME/qbittorrent-nox $HOME/bin/qbittorrent-nox
	mkdir -p $HOME/qbittorrent/Downloads
    mkdir -p $HOME/.config/qBittorrent

	## Configure qBittorrent
	# Check for Virtual Environment since some of the tunning might not work on virtual machine
	systemd-detect-virt > /dev/null
	if [ $? -eq 0 ]; then
		warn "Virtualization is detected, skipping some of the tunning"
		aio=8
		low_buffer=3072
		buffer=15360
		buffer_factor=200
	else
		#Determine if it is a SSD or a HDD
		disk_name=$(printf $(lsblk | grep -m1 'disk' | awk '{print $1}'))
		disktype=$(cat /sys/block/$disk_name/queue/rotational)
		if [ "${disktype}" == 0 ]; then
			aio=12
			low_buffer=5120
			buffer=20480
			buffer_factor=250
		else
			aio=4
			low_buffer=3072
			buffer=10240
			buffer_factor=150
		fi
	fi

    if [[ "${qb_ver}" =~ "4.1." ]]; then
        md5password=$(echo -n $password | md5sum | awk '{print $1}')
        cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[BitTorrent]
Session\AsyncIOThreadsCount=$aio
Session\SendBufferLowWatermark=$low_buffer
Session\SendBufferWatermark=$buffer
Session\SendBufferWatermarkFactor=$buffer_factor

[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=$qb_incoming_port
Downloads\DiskWriteCacheSize=$qb_cache
Downloads\SavePath=/home/$username/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=$qb_port
WebUI\Username=$username
EOF
    elif [[ "${qb_ver}" =~ "4.2."|"4.3." ]]; then
        wget  https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/$arch/qb_password_gen && chmod +x $HOME/qb_password_gen
        #Check if the download is successful
		if [ $? -ne 0 ]; then
			warn "Failed to download qb_password_gen"
			#Clean up
			rm -r $HOME/qbittorrent/Downloads
			rm -r $HOME/.config/qBittorrent
			rm $HOME/bin/qbittorrent-nox
			return 1
		fi
		PBKDF2password=$($HOME/qb_password_gen $password)
        cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[BitTorrent]
Session\AsyncIOThreadsCount=$aio
Session\SendBufferLowWatermark=$low_buffer
Session\SendBufferWatermark=$buffer
Session\SendBufferWatermarkFactor=$buffer_factor

[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=$qb_incoming_port
Downloads\DiskWriteCacheSize=$qb_cache
Downloads\SavePath=/home/$username/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$qb_port
WebUI\Username=$username
EOF
	rm qb_password_gen
    elif [[ "${qb_ver}" =~ "4.4."|"4.5."|"4.6." ]]; then
        wget  https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/$arch/qb_password_gen && chmod +x $HOME/qb_password_gen
        #Check if the download is successful
		if [ $? -ne 0 ]; then
			warn "Failed to download qb_password_gen"
			#Clean up
			rm -r $HOME/qbittorrent/Downloads
			rm -r $HOME/.config/qBittorrent
			rm $HOME/bin/qbittorrent-nox
			return 1
		fi
		PBKDF2password=$($HOME/qb_password_gen $password)
        cat << EOF >$HOME/.config/qBittorrent/qBittorrent.conf
[Application]
MemoryWorkingSetLimit=$qb_cache

[BitTorrent]
Session\AsyncIOThreadsCount=$aio
Session\DefaultSavePath=/home/$username/qbittorrent/Downloads/
Session\DiskCacheSize=$qb_cache
Session\Port=$qb_incoming_port
Session\QueueingSystemEnabled=false
Session\SendBufferLowWatermark=$low_buffer
Session\SendBufferWatermark=$buffer
Session\SendBufferWatermarkFactor=$buffer_factor

[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$qb_port
WebUI\Username=$username
EOF
    rm qb_password_gen
    fi
}

# Allow user to choose installation method Local User Service or Screen or Daemon
qbittorrent_autostart_(){
	need_input "Choose your installation method:"
	select e in "Local User Service" "Screen" "Daemon"
	do
		case $e in
		"Local User Service"|"Screen"|"Daemon")
			break
			;;
		*) warn "Please choose a valid installation method" ;;
		esac
	done

	# Local User Service
	if [[ "${e}" == "Local User Service" ]]; then
		if [ ! -x "$(command -v systemctl)" ]; then
			fail "Systemd is not installed, please use another installation method"
			warn "Trying Screen method"
			e="Screen"
		else
			mkdir -p $HOME/.config/systemd/user/
			touch $HOME/.config/systemd/user/qbittorrent-nox.service
			cat << EOF >$HOME/.config/systemd/user/qbittorrent-nox.service
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
		fi
	fi

	# Screen
	if [[ "${e}" == "Screen" ]]; then
		if [ ! -x "$(command -v screen)" ]; then
			fail "Screen is not installed, please use another installation method"
			warn "Trying Daemon method"
			e="Daemon"
		else
			screen -dmS qBittorrent-nox $HOME/bin/qbittorrent-nox
			# Automatic Restart
			touch $HOME/.qBittorrent-restart.sh
			cat << EOF >$HOME/.qBittorrent-restart.sh
#!/bin/bash

[[ \$(pgrep -f 'qbittorrent-nox') ]] || screen -dmS qBittorrent-nox $HOME/bin/qbittorrent-nox
EOF
			chmod +x $HOME/.qBittorrent-restart.sh
			crontab -l | { cat; echo "*/1 * * * * $HOME/.qBittorrent-restart.sh"; } | crontab -
		fi
	fi

	# Daemon
	if [[ "${e}" == "Daemon" ]]; then
		$HOME/bin/qbittorrent-nox -d
		# Automatic Restart
		touch $HOME/.qBittorrent-restart.sh
		cat << EOF > $HOME/.qBittorrent-restart.sh
#!/bin/bash

[[ \$(pgrep -f 'qbittorrent-nox') ]] || $HOME/bin/qbittorrent-nox -d
EOF
		chmod +x $HOME/.qBittorrent-restart.sh
		crontab -l | { cat; echo "*/1 * * * * $HOME/.qBittorrent-restart.sh"; } | crontab -
	fi
}

## Main
tput sgr0; clear
cd $HOME
info "Installing qBittorrent"

qb_install_check
install_qBittorrent_ $username $password $qb_ver $lib_ver $qb_cache $qb_port $qb_incoming_port
qbittorrent_autostart_

tput sgr0; clear
if pgrep -i -f qbittorrent; then
	info "qBittorrent is running"
	boring_text "qBittorrent WebUI: http://$publicip:$qb_port"
	boring_text "Username: $username"
	boring_text "Password: $password"
else
	fail "Failed to start qBittorrent"
	#Clean up
	rm -r $HOME/qbittorrent/Downloads
	rm -r $HOME/.config/qBittorrent
	rm $HOME/bin/qbittorrent-nox
fi