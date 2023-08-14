#!/bin/bash

WIREGUARD_BIN="/usr/bin/wg"

echo "Updating the system..."
echo
apt update

if [ ! -f "$WIREGUARD_BIN" ]; then
    echo "Installing wireguard..."
    echo
    apt install wireguard -y
fi

# file security
umask 077

# create private key and derive the public key from it
echo "Creating private and public key"
echo
wg genkey | tee privatekey | wg pubkey > publickey

# create virtual interface
echo "Creating virtual interface"
echo
ip link add dev wg0 type wireguard
echo

# add peers
echo "Adding 2 peers, a server and a client"
echo
ip address add dev wg0 192.168.2.1 peer 192.168.2.2

# configure wg0
wg set wg0 listen-port 51820 private-key /root/privatekey
