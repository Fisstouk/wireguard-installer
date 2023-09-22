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

# Packages

The script will intall the following packages:
- wireguard
- [ufw](https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29)

# `peer.conf` file

When the script has finished, you can retrieve the `peer.conf` file in `/etc/wireguard/peer.conf` path. Install this file on your peer so you can access the server where Wireguard is installed (where you previously run this script).

# Endpoint address

In the `peer.conf` file, you will need to change the Endpoint address to the public IP address of your server, in a NAT configuration for example.

# Adding a new peer

By default, the script will only allow one peer to access the server. To allow multiple peers, make sure you have the correct network CIDR (on the script it is a /29 CIDR), follow the steps below and add them to the script:
- Choose a new IP address for the peer, for example `192.168.2.3/29`
- Generate a new pair of keys: `wg genkey | tee privatekey_peer2 | wg pubkey > publickey_peer2`
- Create a new `peer2.conf` file for the new peer to be added
- Add the public key of the new peer to the server configuration file: `wg set  wg0 peer ${public_key_peer2} allowed-ips ${ip_address_peer2_no_cird}`
