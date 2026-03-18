# 🔗 Conectando Dispositivos - Guia Avançado

## Visão Geral

Este guia aborda técnicas avançadas de conexão entre dispositivos no EVE-NG, incluindo VLANs, bridges, túneis e integração com redes reais.

## 🌉 Tipos de Conexões

### 1. Network (Bridge/Switch)

**Uso**: Conectar múltiplos dispositivos na mesma rede L2

**Características**:

- ✅ Simples e eficiente
- ✅ Simula switch não-gerenciável
- ✅ Broadcast domain único

**Quando usar**:

- Conectar dispositivos na mesma subnet
- Simular rede local simples

### 2. Cloud (Nuvem)

**Tipos disponíveis**:

**Cloud0 (pnet0)** - Management:

- Conecta à interface de gerenciamento do EVE-NG
- Acesso à rede física do host
- ✅ Acesso à internet

**Cloud1-9 (pnet1-9)** - Bridges adicionais:

- Requer configuração adicional
- Múltiplas redes isoladas

**Quando usar**:

- Conectar lab à internet
- Acesso a recursos externos
- Integração com rede física

### 3. Conexão Direta (Ponto a Ponto)

**Como fazer**:

1. Arraste cabo de dispositivo A para dispositivo B
2. Selecione interfaces específicas

**Características**:

- ✅ Menor overhead
- ✅ Link ponto-a-ponto dedicado
- Ideal para WAN links

**Quando usar**:

- Links WAN entre roteadores
- Conexões dedicadas
- Economia de recursos

## 🏗️ Topologias Comuns

### Topologia 1: Star (Estrela)

```
        [Router Central]
       /    |    |    \
      /     |    |     \
   [R1]   [R2] [R3]   [R4]
```

**Uso**: Redes hub-and-spoke, DMVPN

**Configuração**:

- Router central: múltiplas interfaces
- Cada spoke conecta diretamente ao hub

### Topologia 2: Full Mesh

```
    [R1]----[R2]
     |\    /|
     | \  / |
     |  \/  |
     |  /\  |
     | /  \ |
    [R3]----[R4]
```

**Uso**: Alta redundância, BGP, OSPF

**Configuração**:

- Cada router conecta a todos os outros
- N(N-1)/2 links para N routers
- ⚠️ Consome mais recursos

### Topologia 3: Multi-Tier (Três Camadas)

```
      [Core-R1]----[Core-R2]
         |            |
    [Dist-R1]    [Dist-R2]
       / \          / \
   [A1][A2]      [A3][A4]
```

**Uso**: Redes empresariais, data centers

**Camadas**:

- **Core**: Backbone de alta velocidade
- **Distribution**: Roteamento entre VLANs
- **Access**: Conexão de dispositivos finais

## 🏷️ VLANs no EVE-NG

### Método 1: VLANs com Switch Linux

**Adicionar Linux Switch**:

1. Add node → Qemu → Linux Switch
2. Configure interfaces necessárias

**Configuração do Switch**:

```bash
# Console do Linux Switch

# Criar bridge
brctl addbr br0

# Adicionar interfaces à bridge
brctl addif br0 eth1
brctl addif br0 eth2
brctl addif br0 eth3

# Subir interfaces
ip link set br0 up
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

# Configurar VLANs com vconfig
vconfig add eth1 10
vconfig add eth2 10
vconfig add eth3 20

# Criar bridges por VLAN
brctl addbr brvlan10
brctl addbr brvlan20

brctl addif brvlan10 eth1.10
brctl addif brvlan10 eth2.10

brctl addif brvlan20 eth3.20

ip link set brvlan10 up
ip link set brvlan20 up
```

### Método 2: VLANs com MikroTik

**No Router MikroTik**:

```routeros
# Criar interfaces VLAN
/interface vlan add name=vlan10 vlan-id=10 interface=ether2
/interface vlan add name=vlan20 vlan-id=20 interface=ether2

# Adicionar IPs
/ip address add address=192.168.10.1/24 interface=vlan10
/ip address add address=192.168.20.1/24 interface=vlan20

# Configurar trunk
/interface bridge add name=bridge1
/interface bridge port add bridge=bridge1 interface=ether3
/interface bridge port add bridge=bridge1 interface=ether4
/interface bridge vlan add bridge=bridge1 vlan-ids=10,20 tagged=ether3,ether4
/interface bridge set bridge1 vlan-filtering=yes
```

## 🌍 Conectar Lab à Internet

### Método 1: NAT via Cloud (Simples)

**Passos**:

1. Adicione Cloud0 (pnet0)
2. Conecte router à Cloud0
3. No router, configure DHCP client ou IP estático
4. Configure NAT no router

**Exemplo MikroTik**:

```routeros
# DHCP na interface WAN
/ip dhcp-client add interface=ether1 disabled=no

# NAT
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
```

### Método 2: Bridge Dedicada

**No EVE-NG**:

```bash
# Criar bridge adicional
brctl addbr pnet1

# Adicionar interface física
brctl addif pnet1 eth0

# Subir bridge
ip link set pnet1 up
```

**No Lab**:

- Use Cloud1 (pnet1) para essa bridge
- Conecte dispositivos

### Método 3: VPN Site-to-Site

**Entre EVE-NG e Rede Externa**:

1. Configure VPN no router do lab (ex: OpenVPN, IPSec)
2. Configure VPN endpoint externo
3. Roteie tráfego através da VPN

## 🔀 Roteamento Entre Redes

### OSPF Multi-Área

**Cenário**: 3 routers, 2 áreas OSPF

```
[R1]--(Area 0)--[R2]--(Area 1)--[R3]
```

**Configuração**:

**Router 1 (ABR - Area Border Router)**:

```routeros
/routing ospf instance add name=default router-id=1.1.1.1
/routing ospf area add name=backbone area-id=0.0.0.0
/routing ospf network add network=10.0.0.0/30 area=backbone
```

**Router 2 (ABR)**:

```routeros
/routing ospf instance add name=default router-id=2.2.2.2
/routing ospf area add name=backbone area-id=0.0.0.0
/routing ospf area add name=area1 area-id=0.0.0.1
/routing ospf network add network=10.0.0.0/30 area=backbone
/routing ospf network add network=10.0.1.0/30 area=area1
```

**Router 3**:

```routeros
/routing ospf instance add name=default router-id=3.3.3.3
/routing ospf area add name=area1 area-id=0.0.0.1
/routing ospf network add network=10.0.1.0/30 area=area1
```

### BGP (Border Gateway Protocol)

**Cenário**: 3 AS (Autonomous Systems)

```
[R1 AS65001]----[R2 AS65002]----[R3 AS65003]
```

**Router 1**:

```routeros
/routing bgp instance set default as=65001 router-id=1.1.1.1
/routing bgp peer add remote-address=10.0.0.2 remote-as=65002
/routing bgp network add network=192.168.1.0/24
```

**Router 2** (Transit AS):

```routeros
/routing bgp instance set default as=65002 router-id=2.2.2.2
/routing bgp peer add remote-address=10.0.0.1 remote-as=65001
/routing bgp peer add remote-address=10.0.1.2 remote-as=65003
```

## 🔒 VPN e Túneis

### GRE Tunnel (Generic Routing Encapsulation)

**Entre R1 e R2**:

**Router 1**:

```routeros
/interface gre add name=gre-tunnel1 remote-address=203.0.113.2 local-address=203.0.113.1
/ip address add address=10.255.255.1/30 interface=gre-tunnel1
```

**Router 2**:

```routeros
/interface gre add name=gre-tunnel1 remote-address=203.0.113.1 local-address=203.0.113.2
/ip address add address=10.255.255.2/30 interface=gre-tunnel1
```

**Roteamento sobre túnel**:

```routeros
# Em ambos routers
/ip route add dst-address=192.168.X.0/24 gateway=10.255.255.X
```

### IPSec VPN

**Site-to-Site IPSec**:

**Router 1** (Initiator):

```routeros
/ip ipsec proposal add name=ike1 pfs-group=modp1024
/ip ipsec peer add address=203.0.113.2 local-address=203.0.113.1
/ip ipsec policy add src-address=192.168.1.0/24 dst-address=192.168.2.0/24 \
    tunnel=yes proposal=ike1 action=encrypt
```

## 📡 Captura de Tráfego

### Método 1: Wireshark Integrado

1. **Botão direito** em um cabo/link
2. **Capture**
3. **Abre Wireshark automaticamente**

### Método 2: tcpdump no Router

**No MikroTik**:

```routeros
/tool sniffer set filter-interface=ether1 streaming-enabled=yes streaming-server=192.168.1.100
/tool sniffer start
```

**No PC com Wireshark**:

- Configure Wireshark para capturar stream TZSP

### Método 3: Port Mirroring

**Espelhar tráfego de uma porta para outra**:

**MikroTik**:

```routeros
# Ainda não suportado nativamente em CHR
# Use packet sniffer ou bridge snooping
```

## 🎛️ QoS e Traffic Shaping

### Limitar Banda (MikroTik)

```routeros
# Queue simples (limite por interface)
/queue simple add name=limit-client target=192.168.10.100/32 \
    max-limit=10M/10M

# Queue tree (mais complexo, mais controle)
/queue type add name=pcq-download kind=pcq pcq-classifier=dst-address
/queue type add name=pcq-upload kind=pcq pcq-classifier=src-address

/queue tree add name=download parent=ether2 packet-mark=all-packets \
    queue=pcq-download max-limit=100M
```

### Priorizar Tráfego

```routeros
# Marcar pacotes VoIP
/ip firewall mangle add chain=forward protocol=udp dst-port=5060 \
    action=mark-packet new-packet-mark=voip-packets

# Dar prioridade
/queue tree add name=voip-priority parent=ether1 packet-mark=voip-packets \
    priority=1 queue=default
```

## 🔧 Troubleshooting de Conectividade

### Diagnóstico Básico

```routeros
# No MikroTik

# Ver interfaces
/interface print

# Ver status de interfaces
/interface monitor-traffic ether1

# Ver tabela ARP
/ip arp print

# Ver MAC addresses aprendidas
/interface bridge host print

# Traceroute
/tool traceroute 8.8.8.8

# Bandwidth test (entre dois MikroTik)
/tool bandwidth-test address=192.168.10.2 duration=10s
```

### Verificar Conectividade L2

```bash
# No Linux

# Ver interfaces
ip link show

# Ver ARP
ip neigh show

# Ver bridges
brctl show

# Capturar tráfego
tcpdump -i eth0 -n
```

### Problemas Comuns

**1. Cabos não conectados no EVE-NG**:

- Verifique visualmente se cabos estão conectados
- Delete e recrie conexão se necessário

**2. Interfaces down**:

```routeros
/interface set ether1 disabled=no
```

**3. Firewall bloqueando**:

```routeros
# Desabilitar temporariamente para teste
/ip firewall filter disable [números]
```

**4. Roteamento incorreto**:

```routeros
# Ver tabela de roteamento
/ip route print

# Adicionar rota manualmente
/ip route add dst-address=192.168.20.0/24 gateway=10.0.0.2
```

## ✅ Checklist de Conexão

- [ ] Cabos conectados fisicamente (visual)
- [ ] Interfaces up (não disabled)
- [ ] IPs configurados corretamente
- [ ] Máscaras de rede corretas
- [ ] Gateway configurado
- [ ] Roteamento configurado (se multi-rede)
- [ ] Firewall não bloqueando (teste desabilitado)
- [ ] ARP funcionando (ip neigh/arp print)
- [ ] Ping local funciona
- [ ] Ping remoto funciona (através de routers)

## 📚 Recursos Adicionais

- **EVE-NG Cookbook**: https://www.eve-ng.net/index.php/documentation/howtos/
- **MikroTik Wiki**: https://wiki.mikrotik.com/
- **Packet Tracer Labs** (converter para EVE-NG)

## 🔄 Próximo Passo

Domine as conexões? Aprenda a resolver problemas:
➡️ [Troubleshooting - Solucionando Problemas](12-troubleshooting.md)

---

**Tempo Estimado**: 1-2 horas (depende da complexidade)  
**Dificuldade**: ⭐⭐⭐⭐☆ (Avançada)
