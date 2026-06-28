/interface ethernet
set [ find default-name=ether1 ] name=ether1-wan-gba-telecom
set [ find default-name=ether2 ] name=ether2-surb-wifi-client
set [ find default-name=ether3 ] disabled=yes
set [ find default-name=ether4 ] disabled=yes

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk,wpa2-eap mode=dynamic-keys name=\
    profile1-wireless supplicant-identity="" wpa2-pre-shared-key=S2z5j8d9@

/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n disabled=no mode=ap-bridge \
    name=wlan1-surb-wifi-client security-profile=profile1-wireless ssid=\
    surb-wifi-client

/ip pool
add name=dhcp_pool1 ranges=192.168.50.10-192.168.50.254
add name=dhcp_pool2 ranges=192.168.60.10-192.168.60.254

/ip dhcp-server
add address-pool=dhcp_pool1 disabled=no interface=ether2-surb-wifi-client name=\
    dhcp1
add address-pool=dhcp_pool2 disabled=no interface=wlan1-surb-wifi-client name=\
    dhcp2

/ip address
add address=192.168.50.1/24 interface=ether2-surb-wifi-client network=\
    192.168.50.0
add address=192.168.60.1/24 interface=wlan1-surb-wifi-client network=\
    192.168.60.0

/ip dhcp-client
add disabled=no interface=ether1-wan-gba-telecom

/ip dhcp-server network
add address=192.168.50.0/24 dns-server=192.168.1.1,8.8.8.8,1.1.1.1 gateway=\
    192.168.50.1
add address=192.168.60.0/24 dns-server=192.168.1.1,8.8.8.8,1.1.1.1 gateway=\
    192.168.60.1

/ip dns
set servers=8.8.8.8,1.1.1.1

/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1-wan-gba-telecom



