# Wireguard server install script

This **bash** script allows you to install a [Wireguard](https://www.wireguard.com/) server on a **Debian** Linux distribution (tested on Debian 11). Once installed on your server, get the *peer.conf* file and install it on your peer to access the server.

# Variables

There is no interaction with the user so if you want to tweak the script, you need to modify some of the following variables: 
- `wireguard_bin`: path of the Wireguard binary, to check if it is installed
- `ufw_bin`: path of the UFW firewall, to check if it is installed 
- `ip_address_server`: IP address of your server for Wireguard
- `ip_address_peer`: IP address of your peer
- `ip_address_peer_no_cidr`: needed for the configuration
- `ip_network_id`: ID of the network for your Wireguard network
- `listen_port`: 51820 by default
- `network_interface`: may vary, depending on your hardware

# Packets

The script will intall the following packets:
- wireguard
- [ufw](https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29)

# `peer.conf` file

When the script has finished, you can retrieve the `peer.conf` file in `/etc/wireguard/peer.conf` path. Install this file on your peer so you can access the server where Wireguard is installed (where you previously run this script).

# Endpoint address

In the `peer.conf` file, you will need to change the Endpoint address to the public IP address of your server, in a NAT configuration for example.
