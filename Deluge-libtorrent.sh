#!/bin/sh

## Load text color settings
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/tput.sh)

## Deluge Tuning
need_input; echo "Please choose your Shared Seedbox Vendor"; normal_3
options=("Feral Hosting - HDD" "Feral Hosting - SSD" "Seedhost.eu - HDD" "Seedhost.eu - SSD" "Seedbox.io" "Swizzin" "Ultra.cc" "qBittorrent 4.3.7 - libtorrent-v1.2.14" "qBittorrent 4.4.0beta2 - libtorrent-v2.0.4")
select opt in "${options[@]}"
do
    case $opt in
        "Feral Hosting - HDD")
            vendor=fhhhd, break
            ;;
        "Feral Hosting - SSD")
            vendor=fhssd, break
            ;;
        "Seedhost.eu - HDD")
            vendor=shhhd, break
            ;;
        "Seedhost.eu - SSD")
            vendor=shssd, break
            ;;
        "Seedbox.io")
            normal_1; Shared App Box has already been pretuned by Seedbox.io. There is no need to run this script; normal_4; exit
            ;;
        "Swizzin")
            normal_1; Alphabet Seedbox has already been pretuned by Swizzin. There is no need to run this script; normal_4; exit
            ;;
        "Ultra.cc")
            version=4.3.7; wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qBittorrent/qBittorrent%204.3.7%20-%20libtorrent-v1.2.14/qbittorrent-nox && chmod +x $HOME/qbittorrent-nox; break
            ;;
        "qBittorrent 4.4.0beta2 - libtorrent-v2.0.4")
            version=4.4.0; wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qBittorrent/qBittorrent%204.4.0beta2%20-%20libtorrent-v2.0.4/qbittorrent-nox && chmod +x $HOME/qbittorrent-nox; break
            ;;
        *) warn_1; echo "Please choose a valid version"; normal_3;;
    esac
done



#ltconfig installation
test -e $HOME/.config/deluge/plugins/ltConfig-0.3.1-py2.7.egg
if [ ! $? -eq 0 ]; then
	noraml_1; echo "Installing ltConfig"; normal_2
	wget https://github.com/ratanakvlun/deluge-ltconfig/releases/download/v0.3.1/ltConfig-0.3.1-py2.7.egg -P $HOME/.config/deluge/plugins
	deluge-console -e ltConfig
	if [ ! $? -eq 0 ]; then
		warn_1; echo "ltConfig Installation failed, please install it manually"; normal_2
fi

#Deluge Libtorrent Config
normal_1; echo "Configuring Deluge Libtorrent Settings"; warn_2
cat << EOF >$HOME/.config/deluge/ltconfig.conf
{
  "file": 1, 
  "format": 1
}{
  "apply_on_start": true, 
  "settings": {
EOF

