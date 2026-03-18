# 🔧 Configuração do MikroTik RouterOS

## Visão Geral

O MikroTik RouterOS é um sistema operacional para roteadores poderoso e versátil. Neste guia, configuraremos o MikroTik CHR (Cloud Hosted Router) no EVE-NG.

## 🚀 Adicionar MikroTik ao Lab

### Passo 1: Criar ou Abrir Lab

1. **Na interface web do EVE-NG**, abra um lab existente ou crie novo

2. **Clique no ícone** "+ Node" (ou clique direito na área de trabalho)

### Passo 2: Selecionar Dispositivo

1. **Node type**: Selecione "QEMU"

2. **Template**: Procure e selecione "MikroTik CHR" ou "mikrotik"

3. **Configurações**:

   ```
   Name: Router-1
   Icon: Router (ou personalizado)
   Number of nodes: 1
   RAM: 256 MB (suficiente para a maioria dos cenários)
   CPU: 1
   Ethernet interfaces: 4 (ou mais se necessário)
   ```

4. **Clique em "Save"**

### Passo 3: Posicionar e Iniciar

1. **Arraste** o dispositivo para posição desejada

2. **Clique direito** no dispositivo → **Start**

3. **Aguarde** o boot (30-60 segundos)

## 🖥️ Primeiro Acesso

### Conectar ao Console

1. **Clique direito** no dispositivo

2. **Selecione** "Console" ou "Telnet"

3. **Login Inicial**:

   ```
   MikroTik Login: admin
   Password: [Enter - sem senha inicialmente]
   ```

4. **Primeira inicialização**:
   ```
   Do you want to see the software license? [Y/n]: n
   ```

## ⚙️ Configuração Básica

### Definir Senha do Admin

```routeros
# No console do MikroTik
/user set admin password=suasenha123

# Confirmar senha
suasenha123
```

### Configurar Identity (Nome do Router)

```routeros
/system identity set name=Router-Lab-1
```

### Verificar Interfaces

```routeros
/interface print

# Saída exemplo:
# 0 R  ether1
# 1 R  ether2
# 2 R  ether3
# 3 R  ether4
```

## 🌐 Configuração de Rede

### Configurar IP em Interface

**Cenário**: Configurar ether1 como interface de gerenciamento

```routeros
# Adicionar IP à ether1
/ip address add address=192.168.1.10/24 interface=ether1

# Verificar
/ip address print
```

### Configurar Gateway Padrão

```routeros
# Adicionar rota padrão
/ip route add gateway=192.168.1.1

# Verificar
/ip route print
```

### Configurar DNS

```routeros
# Definir servidores DNS
/ip dns set servers=8.8.8.8,8.8.4.4

# Habilitar cliente DNS
/ip dns set allow-remote-requests=yes

# Verificar
/ip dns print
```

## 🔒 Configurações de Segurança

### Desabilitar Serviços Desnecessários

```routeros
# Ver serviços ativos
/ip service print

# Desabilitar serviços não utilizados
/ip service disable telnet
/ip service disable ftp
/ip service disable www
/ip service disable api
/ip service disable api-ssl

# Manter apenas SSH e Winbox
/ip service enable ssh
/ip service enable winbox
```

### Configurar SSH

```routeros
# Trocar porta SSH (opcional, recomendado)
/ip service set ssh port=2222

# Configurar chaves SSH (opcional avançado)
```

### Criar Usuário Adicional

```routeros
# Criar novo usuário
/user add name=operador password=senhaoperador group=full

# Grupos disponíveis:
# - read: apenas leitura
# - write: leitura e escrita
# - full: controle total
```

## 🛠️ Configurações Comuns

### Configurar DHCP Server

**Cenário**: DHCP na rede 192.168.10.0/24 na ether2

```routeros
# Adicionar IP à interface
/ip address add address=192.168.10.1/24 interface=ether2

# Criar pool de IPs
/ip pool add name=dhcp_pool ranges=192.168.10.10-192.168.10.100

# Configurar DHCP Server
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8

# Adicionar DHCP Server
/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool disabled=no

# Verificar
/ip dhcp-server print
/ip dhcp-server lease print
```

### Configurar NAT (Masquerade)

**Cenário**: NAT para permitir internet aos clientes

```routeros
# Configurar masquerade (NAT)
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Verificar
/ip firewall nat print
```

### Configurar Firewall Básico

```routeros
# Permitir conexões estabelecidas/relacionadas
/ip firewall filter add chain=input connection-state=established,related action=accept

# Permitir ICMP (ping)
/ip firewall filter add chain=input protocol=icmp action=accept

# Permitir acesso de rede local
/ip firewall filter add chain=input in-interface=ether2 action=accept

# Permitir SSH de rede específica
/ip firewall filter add chain=input protocol=tcp dst-port=22 src-address=192.168.1.0/24 action=accept

# Bloquear todo resto
/ip firewall filter add chain=input action=drop

# Verificar regras
/ip firewall filter print
```

## 📡 Roteamento

### Roteamento Estático

```routeros
# Adicionar rota estática
/ip route add dst-address=10.0.0.0/8 gateway=192.168.1.254

# Ver tabela de roteamento
/ip route print

# Remover rota
/ip route remove [número]
```

### OSPF (Exemplo Básico)

```routeros
# Criar instância OSPF
/routing ospf instance add name=default router-id=1.1.1.1

# Adicionar área
/routing ospf area add name=backbone area-id=0.0.0.0

# Adicionar redes
/routing ospf network add network=192.168.10.0/24 area=backbone
/routing ospf network add network=192.168.20.0/24 area=backbone

# Verificar vizinhos
/routing ospf neighbor print

# Ver tabela OSPF
/routing ospf route print
```

## 🔗 Bridge (Switching)

### Criar Bridge

```routeros
# Criar bridge
/interface bridge add name=bridge1

# Adicionar portas à bridge
/interface bridge port add bridge=bridge1 interface=ether2
/interface bridge port add bridge=bridge1 interface=ether3
/interface bridge port add bridge=bridge1 interface=ether4

# Adicionar IP à bridge
/ip address add address=192.168.100.1/24 interface=bridge1

# Verificar
/interface bridge print
/interface bridge port print
```

## 📊 Monitoramento e Diagnóstico

### Comandos Úteis

```routeros
# Ver uso de recursos
/system resource print

# Ver interfaces e tráfego
/interface print stats

# Monitorar tráfego em interface
/interface monitor-traffic ether1

# Ping
/ping 8.8.8.8 count=4

# Traceroute
/tool traceroute 8.8.8.8

# Ver conexões ativas
/ip firewall connection print

# Ver logs
/log print
/log print follow

# Ver uptime
/system clock print
```

### SNMP (Monitoramento Externo)

```routeros
# Habilitar SNMP
/snmp set enabled=yes contact="Admin" location="Lab"

# Definir community (cuidado com segurança!)
/snmp community add name=public addresses=192.168.1.0/24
```

## 💾 Backup e Restore

### Criar Backup

```routeros
# Backup binário (completo)
/system backup save name=backup-lab-$(date)

# Export de configuração (texto)
/export file=config-lab-$(date)

# Verificar arquivos
/file print
```

### Download de Backup

Via FTP ou através da interface Winbox:

1. Conecte via Winbox
2. Files → Download

### Restaurar Backup

```routeros
# Restaurar backup binário
/system backup load name=backup-lab-20260318

# Importar configuração
/import file=config-lab-20260318.rsc
```

## 🎯 Configurações para Laboratório

### Resetar Configuração

```routeros
# Reset completo (CUIDADO!)
/system reset-configuration no-defaults=yes skip-backup=yes

# Ou com configuração padrão
/system reset-configuration
```

### Configuração Rápida para Testes

```routeros
# Script de configuração básica
/system identity set name=Lab-Router
/user set admin password=admin123
/ip address add address=192.168.1.1/24 interface=ether1
/ip address add address=10.0.0.1/24 interface=ether2
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
/ip dns set servers=8.8.8.8
```

## 🔧 Troubleshooting

### Router não responde

```routeros
# Verificar interfaces
/interface print

# Ver se interfaces estão "R" (running)
# Se "X", pode estar desconectada no EVE-NG
```

### Sem conectividade

```routeros
# Verificar rotas
/ip route print

# Ping gateway
/ping [gateway-ip]

# Ver ARP
/ip arp print

# Verificar firewall
/ip firewall filter print
/ip firewall nat print
```

### Esquecer senha

**Solução**: Resetar o MikroTik

- No EVE-NG, delete o node e crie novo
- Ou reset via console (se tiver acesso físico em hardware real)

### Performance ruim

```routeros
# Ver uso de recursos
/system resource print

# Ver CPU load
# CPU load deve estar < 80% idealmente

# Verificar memória
# Free memory deve ser > 20%
```

## ✅ Checklist de Configuração Básica

- [ ] Senha do admin definida
- [ ] Nome do router configurado (identity)
- [ ] IP de gerenciamento configurado
- [ ] Gateway padrão definido
- [ ] DNS configurado
- [ ] Serviços desnecessários desabilitados
- [ ] SSH habilitado
- [ ] Firewall básico configurado
- [ ] NAT configurado (se necessário)
- [ ] Backup da configuração salvo

## 📚 Comandos de Referência Rápida

```routeros
# Modo de ajuda
?

# Help de comando específico
/ip address ?

# Auto-completar
[Tab]

# Histórico de comandos
[Setas ↑ ↓]

# Sair
/quit

# Cancelar comando
[Ctrl+C]
```

## 🔄 Próximo Passo

MikroTik configurado? Prossiga para:
➡️ [Configuração do Servidor Linux](08-configuracao-servidor-linux.md)

---

**Tempo Estimado**: 20-30 minutos  
**Dificuldade**: ⭐⭐⭐☆☆ (Média)  
**Documentação Oficial**: https://wiki.mikrotik.com/
