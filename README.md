## !!!! When used with Ultra.cc (a.k.a. Ultraseedbox), the static build qBittorrent will falsely report more upload during pause/resume and reannounce. This could get you banned from the private trackers. Please install qBittorrent using their panel instead.

# Shared-Seedbox
<details>
  <summary>qBittorrent & autoremove-torrents Install</summary>
    
## Usage
`bash <(wget -qO- https://raw.githubusercontent.com/jerry048/Shared-Seedbox/main/qBittorrent.sh) <Username> <Password> <WebUI Port> <Port used for incoming connections> <Cache Size(unit:MiB)>`
## Functions
Install qBittorrent with tweaked libtorrent settings & autoremove-torrents with minimum config. This script does not require root to run so it should support most Shared Seedbox.
### Currently availble qBittorrent Versions:

    | qBittorrent 4.1.9   | libtorrent-1_1_14  |
    | qBittorrent 4.1.9.1 | libtorrent-1_1_14  |
    | qBittorrent 4.3.3   | libtorrent-v1.2.13 |
    | qBittorrent 4.3.4.1 | libtorrent-v1.2.13 |
    | qBittorrent 4.3.5   | libtorrent-v1.2.13 |
### Current availble Installation Method:
    Local User Service 
    Screen
    Daemon 
### Shared seedbox supports （Only for reference)
    1. Dediseedbox - qBittorrent in not connectable* since the SSH is built inside docker
        Please add WebUI\HostHeaderValidation=false to the config
        Need to use ssh tunneling to access the WebUI
        
    2. Feralhosting - Use screen or Daemon installation Method
        
    3. Ultra.cc - Do not use this script
    
    4. Whatbox - Use screen or Daemon installation Method
### Credit
    qBittorrent Install - https://github.com/userdocs/qbittorrent-nox-static

    qBittorrent Password Set - https://github.com/KozakaiAya/libqbpasswd & https://amefs.net/archives/2027.html

    autoremove-torrents - https://github.com/jerrymakesjelly/autoremove-torrents
    
    And N3ON for pointing out numerous bugs
    
*Connectability - Ability of your client to accept incoming connections from other clients, to facilitate transferring data.  Two unconnectable clients can not communicate, which is why having people connectable in a swarm is important. *~From MAM*

</details>

<details>
  <summary>Bandwidth Monitor</summary>

## Usage
`bash <(wget -qO- https://raw.githubusercontent.com/jerry048/Shared-Seedbox/main/Bandwidth_Usage.sh)`
## Functions
Monitor Bandwidth Usage of the Machine in situation where nload, vnstat, etc. are unavailable.
