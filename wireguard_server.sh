#!/bin/bash

wireguard_bin="/usr/bin/wg"
ufw_bin="/usr/sbin/ufw"
ip_address_server="192.168.2.1/29"
ip_address_peer="192.168.2.2/29"
ip_address_peer_no_cidr="192.168.2.2"
ip_network_id="192.168.2.0/29"
listen_port="51820"
network_interface="enp0s3"

echo "Updating the system..."
echo
apt update

# install wireguard

if [ ! -f "${wireguard_bin}" ]; then
    echo "Installing Wireguard..."
    sleep 5
    echo
    apt install wireguard -y
fi

# install ufw

if [ ! -f "${ufw_bin}" ]; then
    echo "Installing UFW"
    sleep 5
    echo
    apt install ufw -y
fi

# file security

umask 077

# create private key and derive the public key from it

echo "Creating private and public key for the server"
sleep 3
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
PostUp = ufw route allow in on wg0 out on ${network_interface} 
PostUp = iptables -t nat -I POSTROUTING -o ${network_interface} -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out ${network_interface}
PreDown = iptables -t nat -D POSTROUTING -o ${network_interface} -j MASQUERADE
EOF

# allow ssh

ufw allow OpenSSH

# allow Wireguard

ufw allow 51820/udp

# restart ufw

y | ufw disable
ufw enable

# starting Wireguard server

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service


echo "Creating private and public key for the peer"
echo
sleep 3
wg genkey | tee privatekey_peer | wg pubkey > publickey_peer

private_key_peer=$(cat privatekey_peer)
public_key_peer=$(cat publickey_peer)

# peer configuration file
# endpoint will be the public ip address

cat > /etc/wireguard/peer.conf << EOF
[Interface]
PrivateKey = ${private_key_peer}
Address = ${ip_address_peer}
ListenPort = ${listen_port}

[Peer]
PublicKey = ${public_key_server}
AllowedIPs = ${ip_network_id}
Endpoint = 100.100.100.100:51820
EOF

# adding peer pubkey to server conf

wg set wg0 peer ${public_key_peer} allowed-ips ${ip_address_peer_no_cidr}
