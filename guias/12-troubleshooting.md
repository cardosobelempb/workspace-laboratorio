# 🔧 Troubleshooting - Solucionando Problemas

## Visão Geral

Este guia aborda problemas comuns no laboratório EVE-NG e suas soluções. Organizado por categoria para fácil navegação.

## 🖥️ Problemas com VMware

### VMware não inicia

**Sintomas**: Erro ao abrir VMware Workstation

**Causas Comuns**:

- Hyper-V habilitado (Windows)
- WSL2 ativo (usa Hyper-V)
- Falta de virtualização na BIOS

**Soluções**:

```cmd
# 1. Desabilitar Hyper-V (como Administrador)
bcdedit /set hypervisorlaunchtype off
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V
shutdown /r /t 0

# 2. Verificar virtualização
systeminfo | findstr /i "virtualization"
# Deve mostrar: "Enabled"

# 3. Reiniciar serviços VMware
net stop "VMware Authorization Service"
net start "VMware Authorization Service"
```

### VM não liga - "No 3D support"

**Solução**:

1. Desligue a VM
2. Edit settings → Display
3. Desmarque "Accelerate 3D graphics"
4. Tente novamente

### Erro: "Binary translation is incompatible"

**Causa**: Windows Defender/Antivírus interferindo

**Solução**:

- Adicione exclusão para VMware no antivírus
- Pasta: `C:\Program Files (x86)\VMware\`
- Processos: `vmware.exe`, `vmware-vmx.exe`

## 🌐 Problemas com EVE-NG

### Não consigo acessar interface web

**Verificações**:

```bash
# 1. VM está ligada?
# No VMware, verifique status da VM

# 2. No console do EVE-NG, verificar IP
ip addr show pnet0

# 3. Ping do seu computador
ping [IP-do-EVE-NG]

# 4. Verificar serviço Apache
systemctl status apache2

# Se não está rodando:
systemctl restart apache2
```

**Se ainda não funciona**:

```bash
# Verificar firewall do EVE-NG
iptables -L

# Desabilitar temporariamente (teste)
iptables -F

# Verificar logs
tail -f /var/log/apache2/error.log
```

### Interface web lenta

**Causas**: RAM/CPU insuficiente

**Soluções**:

1. **Aumentar recursos da VM**:
   - RAM: mínimo 8GB, ideal 16GB+
   - CPU: 4+ cores

2. **No EVE-NG, otimizar**:

```bash
# Habilitar UKSM (memory deduplication)
echo 1 > /sys/kernel/mm/uksm/run

# Aumentar swap
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

3. **Usar navegador Chrome** (melhor performance)

### Esqueci senha do EVE-NG

**Senha do root (console/SSH)**:

```bash
# 1. Reinicie a VM
# 2. No GRUB, pressione 'e' para editar
# 3. Encontre linha que começa com 'linux'
# 4. No final da linha, adicione: init=/bin/bash
# 5. Pressione Ctrl+X para boot

# No shell emergencial:
mount -o remount,rw /
passwd root
# Digite nova senha
sync
reboot -f
```

**Senha do admin (web)**:

```bash
# Via SSH como root
mysql -u root -p
# Senha padrão: eve

USE eve_ng_db;
UPDATE users SET password=MD5('novasenha') WHERE username='admin';
exit;
```

## 🔌 Problemas de Conectividade

### Dispositivos não pingam (mesma rede)

**Diagnóstico passo a passo**:

**1. Verificar conexões no EVE-NG**:

- Cabos visualmente conectados?
- Cor dos cabos (cinza = desconectado)

**2. Verificar interfaces**:

```routeros
# No MikroTik
/interface print
# Deve mostrar "R" (running), não "X"

# Se "X", habilitar:
/interface set ether1 disabled=no
```

```bash
# No Linux
ip link show
# Deve mostrar "UP", não "DOWN"

# Se DOWN, subir:
sudo ip link set eth0 up
```

**3. Verificar IPs**:

```routeros
# MikroTik
/ip address print
```

```bash
# Linux
ip addr show
```

**4. Verificar ARP**:

```routeros
# MikroTik
/ip arp print
# Deve mostrar MAC do dispositivo destino
```

```bash
# Linux
ip neigh show
```

**5. Verificar firewall**:

```routeros
# MikroTik - desabilitar temporariamente
/ip firewall filter disable [números]

# Testar ping
# Se funcionar, problema está no firewall
```

### Sem acesso à internet do lab

**Verificações**:

```routeros
# 1. Router tem IP no WAN?
/ip address print

# 2. Gateway configurado?
/ip route print
# Deve ter rota padrão (0.0.0.0/0)

# 3. DNS funciona?
/ip dns print
/ping 8.8.8.8
/ping google.com

# 4. NAT configurado?
/ip firewall nat print
# Deve ter regra: chain=srcnat action=masquerade
```

**Solução comum**:

```routeros
# Adicionar NAT se faltando
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Adicionar DNS
/ip dns set servers=8.8.8.8,8.8.4.4

# Adicionar rota padrão (se DHCP não adicionou)
/ip route add gateway=[IP-do-gateway]
```

## 💾 Problemas com Imagens/Dispositivos

### Imagem não aparece no EVE-NG

**Verificações**:

```bash
# 1. Arquivo existe?
ls -lh /opt/unetlab/addons/qemu/mikrotik-7.9/

# Deve ter:
# virtioa.qcow2 (ou hda.qcow2)

# 2. Permissões corretas?
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions

# 3. Nome da pasta correto?
# Formato: tipo-nome-versao
# Exemplo: mikrotik-7.9

# 4. Limpar cache do navegador
# Ctrl+Shift+R (recarregar forçado)
```

### Erro: "Cannot start node"

**Causas e Soluções**:

**1. RAM insuficiente**:

```bash
# Ver RAM disponível
free -h

# Se pouca RAM livre:
# - Aumente RAM da VM EVE-NG
# - Ou pare outros dispositivos
```

**2. Disco corrupto**:

```bash
# Verificar disco
cd /opt/unetlab/addons/qemu/[dispositivo]/
/opt/qemu/bin/qemu-img check virtioa.qcow2

# Se corrupto, recriar:
rm virtioa.qcow2
/opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 20G
```

**3. Virtualização aninhada não habilitada**:

- No VMware, Edit settings da VM EVE-NG
- Processors → ✅ "Virtualize Intel VT-x/EPT or AMD-V/RVI"
- Reinicie a VM EVE-NG

### Dispositivo muito lento

**Soluções**:

```bash
# 1. Verificar recursos
htop
# CPU > 80%? Adicione mais cores
# Swap alto? Adicione mais RAM

# 2. Habilitar UKSM
echo 1 > /sys/kernel/mm/uksm/run

# 3. Reduzir dispositivos simultâneos

# 4. Usar imagens mais leves
# Ex: MikroTik 256MB RAM é suficiente, não use 1GB

# 5. Verificar disco I/O
iotop
# Se alto, use SSD para VMs
```

## 🔧 Problemas com Dispositivos Específicos

### MikroTik não responde

**Soluções**:

```routeros
# 1. Verificar CPU load
/system resource print
# CPU load > 100%? Problema de configuração

# 2. Ver logs
/log print

# 3. Verificar processos
/system resource monitor
```

**Reset de configuração**:

```routeros
# CUIDADO: Apaga toda configuração!
/system reset-configuration no-defaults=yes skip-backup=yes

# Ou no EVE-NG:
# Botão direito → Stop → Wipe → Start
```

### Linux não inicia (boot loop)

**Causas**:

- Disco cheio
- Fstab incorreto
- Kernel panic

**Soluções**:

```bash
# Boot em recovery mode
# No GRUB, selecione "Advanced options" → "Recovery mode"

# Verificar disco
df -h

# Limpar espaço se cheio
apt clean
apt autoremove

# Verificar fstab
nano /etc/fstab
# Comente linhas problemáticas com #
```

## 🌐 Problemas de Rede Específicos

### DHCP não funciona

**No servidor DHCP (MikroTik)**:

```routeros
# Verificar DHCP server está habilitado
/ip dhcp-server print
# Status deve ser "X" (running)

# Ver leases
/ip dhcp-server lease print

# Ver logs
/log print topics=dhcp

# Teste manual: colocar IP estático no cliente
# Se funciona, problema está no DHCP
```

### DNS não resolve

**Verificações**:

```bash
# No cliente Linux
cat /etc/resolv.conf
# Deve ter nameservers

# Testar DNS específico
nslookup google.com 8.8.8.8

# Se funciona, problema é DNS local
```

**No router (MikroTik)**:

```routeros
# Verificar DNS
/ip dns print

# Testar
/ping google.com

# Se falha:
/ip dns set servers=8.8.8.8,8.8.4.4
```

### OSPF neighbors não formam

**Verificações**:

```routeros
# Ver interfaces OSPF
/routing ospf interface print

# Ver neighbors
/routing ospf neighbor print
# Status deve ser "Full"

# Ver logs
/log print topics=ospf
```

**Problemas comuns**:

- Area ID diferente
- Network type incompatível
- Hello/Dead timers diferentes
- MTU mismatch

**Soluções**:

```routeros
# Verificar configuração
/routing ospf network print

# Forçar network type
/routing ospf interface set [número] network-type=broadcast

# Ajustar timers (se necessário)
/routing ospf interface set [número] hello-interval=10 dead-interval=40
```

## 🔒 Problemas de Segurança

### Não consigo acessar dispositivo via SSH

**Verificações**:

```bash
# 1. SSH está rodando?
systemctl status sshd

# 2. Porta correta?
cat /etc/ssh/sshd_config | grep Port

# 3. Firewall bloqueando?
sudo ufw status

# Permitir SSH:
sudo ufw allow 22/tcp
```

**No MikroTik**:

```routeros
# Verificar serviço SSH
/ip service print

# Habilitar se desabilitado
/ip service set ssh disabled=no

# Verificar porta
/ip service set ssh port=22
```

### Firewall bloqueando tudo

**Diagnóstico**:

```routeros
# Ver regras
/ip firewall filter print

# Desabilitar temporariamente (TESTE APENAS!)
/ip firewall filter disable [números]

# Se funciona, problema está nas regras
```

**Regra básica segura**:

```routeros
# Reset firewall (CUIDADO!)
/ip firewall filter remove [números]

# Adicionar regras básicas
/ip firewall filter add chain=input connection-state=established,related action=accept
/ip firewall filter add chain=input protocol=icmp action=accept
/ip firewall filter add chain=input in-interface=ether2 action=accept
/ip firewall filter add chain=input protocol=tcp dst-port=22 action=accept
/ip firewall filter add chain=input action=drop
```

## 📊 Ferramentas de Diagnóstico

### Comandos Essenciais

**MikroTik**:

```routeros
/system resource print
/interface print stats
/ip address print
/ip route print
/ping 8.8.8.8
/tool traceroute 8.8.8.8
/log print
```

**Linux**:

```bash
ip addr show
ip route show
ping -c 4 8.8.8.8
traceroute 8.8.8.8
ss -tuln
netstat -rn
journalctl -xe
```

**EVE-NG**:

```bash
htop
df -h
free -h
virsh list
systemctl status apache2
tail -f /var/log/apache2/error.log
```

## ✅ Checklist de Diagnóstico

Use esta sequência para qualquer problema de rede:

- [ ] **Camada 1 (Física)**: Cabos conectados? Interfaces UP?
- [ ] **Camada 2 (Enlace)**: ARP funciona? MAC addresses corretos?
- [ ] **Camada 3 (Rede)**: IPs configurados? Ping local funciona?
- [ ] **Camada 3 (Roteamento)**: Gateway configurado? Rotas corretas?
- [ ] **Camada 4 (Transporte)**: Portas abertas? Firewall permite?
- [ ] **Camada 7 (Aplicação)**: Serviço rodando? Configuração correta?

## 🆘 Quando Buscar Ajuda

Se nada funcionar, colete estas informações antes de pedir ajuda:

1. **Topologia**: Diagrama ou descrição
2. **Sintoma exato**: O que não funciona?
3. **O que testou**: Ping? Traceroute?
4. **Configurações**: IPs, rotas, firewall
5. **Logs**: Erros específicos
6. **Versões**: EVE-NG, RouterOS, etc.

## 📚 Recursos de Suporte

- **Fórums EVE-NG**: https://www.eve-ng.net/index.php/community/
- **MikroTik Forum**: https://forum.mikrotik.com/
- **Reddit r/Mikrotik**: https://www.reddit.com/r/mikrotik/
- **Documentação**: Ver guias específicos neste repositório

## 🔄 Próximo Passo

Ainda tem dúvidas? Consulte:
➡️ [FAQ - Perguntas Frequentes](13-faq.md)

---

**Dica**: Mantenha backups regulares de suas configurações!
