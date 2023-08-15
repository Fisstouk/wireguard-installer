#!/bin/bash

wireguard_bin="/usr/bin/wg"
ip_address_server="192.168.2.1/29"
listen_port="51820"

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
wg genkey | tee privatekey_server | wg pubkey > publickey_server

private_key_server=$(cat privatekey_server)
public_key_server=$(cat publickey_server)

# server configuration file

cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = ${private_key_server}
Address = ${ip_address_server}
ListenPort = ${listen_port}
SaveConfig = true
EOF
 
# network forwarding
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
