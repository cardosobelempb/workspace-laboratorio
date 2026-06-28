# === MIKROTIK-001 (AS 65100, cliente da Vivo) - cole via SSH/Winbox ===
/system identity set name=MIKROTIK-001
/ip address add address=10.250.0.50/24 interface=ether1 comment=backbone
/ip address add address=192.168.100.1/24 interface=lo comment=LAN-cliente
/routing bgp connection
add name=to-VIVO remote.address=10.250.0.10 as=65100 remote.as=65010 \
    address-families=ip output.network=bgp-nets local.role=ebgp
/routing bgp network add network=192.168.100.0/24 synchronize=no
# NAT exemplo (se for rotear uma LAN real por aqui):
# /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
