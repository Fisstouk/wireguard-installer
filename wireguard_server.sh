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
