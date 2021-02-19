# Shared-Seedbox
## Usage
`curl -s -O https://raw.githubusercontent.com/jerry048/Shared-Seedbox/main/shared-seedbox.sh && chmod +x shared-seedbox.sh && bash shared-seedbox.sh <Personal access tokens> <username> <password> <port>`
## Functions
Install qBittorrent with tweaked libtorrent settings & autoremove-torrents with minimum config. This script does not require root to run so it should support most Shared Seedbox.
### Currently availble qBittorrent Versions:

    | qBittorrent 4.1.9   | libtorrent-1_1_14  |
    | qBittorrent 4.1.9.1 | libtorrent-1_1_14  |
    | qBittorrent 4.3.2   | libtorrent-v1.2.12 |
    | qBittorrent 4.3.3   | libtorrent-v1.2.12 |

### Current availble Installation Method:
    Local User Service 
    Screen
    Daemon
### Shared seedbox supports
    Dediseedbox - Need to use ssh tunneling - Not Worth it
        Please add WebUI\HostHeaderValidation=false to the config
    Whatbox - Use screen or Daemon installation Method

