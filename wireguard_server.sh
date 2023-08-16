#!/bin/bash

wireguard_bin="/usr/bin/wg"
ip_address_server="192.168.2.1/29"
listen_port="51820"

echo "Updating the system..."
echo
apt update

# install wireguard

if [ ! -f "$WIREGUARD_BIN" ]; then
    echo "Installing wireguard..."
    echo
    apt install wireguard -y
fi

# file security

umask 077

# create private key and derive the public key from it

echo "Creating private and public key for the server"
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

# firewall rules

cat >> /etc/wireguard/wg0.conf << EOF
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

# allow ssh

ufw allow OpenSSH

# restart ufw

ufw disable
ufw enable

# starting Wireguard server

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service
