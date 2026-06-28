# === CLARO-CORE (AS 65020) - cole via SSH/Winbox ===
/system identity set name=CLARO-CORE
/ip address add address=10.250.0.20/24 interface=ether1 comment=backbone
/ip address add address=172.16.20.1/24 interface=lo
/routing bgp connection
add name=to-VIVO remote.address=10.250.0.10 as=65020 remote.as=65010 \
    address-families=ip output.network=bgp-nets local.role=ebgp
/routing bgp network add network=172.16.20.0/24 synchronize=no
