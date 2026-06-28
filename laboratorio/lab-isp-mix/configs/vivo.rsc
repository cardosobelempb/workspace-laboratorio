# === VIVO-CORE (AS 65010) - hub do BGP - cole via SSH/Winbox ===
/system identity set name=VIVO-CORE
/ip address add address=10.250.0.10/24 interface=ether1 comment=backbone
/ip address add address=172.16.10.1/24 interface=lo
/routing bgp connection
add name=to-CLARO  remote.address=10.250.0.20 as=65010 remote.as=65020 address-families=ip output.network=bgp-nets local.role=ebgp
add name=to-GOIAS  remote.address=10.250.0.30 as=65010 remote.as=65030 address-families=ip output.network=bgp-nets local.role=ebgp
add name=to-CONTAB remote.address=10.250.0.40 as=65010 remote.as=65040 address-families=ip output.network=bgp-nets local.role=ebgp
add name=to-MIKRO  remote.address=10.250.0.50 as=65010 remote.as=65100 address-families=ip output.network=bgp-nets local.role=ebgp
/routing bgp network add network=172.16.10.0/24 synchronize=no
# troque a senha: /user set admin password=SUASENHA
