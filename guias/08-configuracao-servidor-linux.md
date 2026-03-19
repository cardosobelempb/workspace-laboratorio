# 🐧 Configuração do Servidor Linux

## Visão Geral

O servidor Linux no laboratório pode atuar como servidor web, DNS, DHCP, FTP, ou qualquer outro serviço necessário para suas práticas. Usaremos Ubuntu Server como exemplo.

## 🚀 Adicionar Servidor ao Lab

### Passo 1: Adicionar Node

1. **No EVE-NG**, abra seu lab

2. **Adicione novo node**:
   - Node type: **QEMU**
   - Template: **Linux Ubuntu Server** (ou sua versão)
   - Name: `Server-1`
   - RAM: `2048 MB` (mínimo), `4096 MB` (recomendado)
   - CPU: `2`
   - Ethernet interfaces: `2`

3. **Clique em "Save"**

### Passo 2: Iniciar e Instalar

1. **Inicie o node** (botão direito → Start)

2. **Conecte ao console** (botão direito → Console)

3. **Boot do installer**:
   - Se configurou com cdrom.iso, o Ubuntu installer iniciará
   - Siga as instruções de instalação

## 💿 Instalação do Ubuntu Server

### Passo 1: Idioma e Teclado

```
Language: English (ou Português)
Keyboard: Brazilian (ou sua preferência)
```

### Passo 2: Tipo de Instalação

```
Selecione: Ubuntu Server
```

### Passo 3: Configuração de Rede (Temporária)

```
Interface: enp0s3 (ou eth0)
IPv4 method: Automatic (DHCP) - configuraremos manualmente depois
```

**Ou configure já**:

```
IPv4 method: Manual
Subnet: 192.168.10.0/24
Address: 192.168.10.10
Gateway: 192.168.10.1
Name servers: 8.8.8.8, 8.8.4.4
```

### Passo 4: Proxy (se necessário)

```
Proxy: [deixe em branco ou configure se necessário]
```

### Passo 5: Mirror

```
Use padrão ou configure mirror brasileiro:
http://br.archive.ubuntu.com/ubuntu
```

### Passo 6: Particionamento de Disco

```
Selecione: Use an entire disk
Disco: /dev/vda (20GB)
```

**Layout sugerido**:

- Partição automática é adequada para laboratório

### Passo 7: Configuração do Sistema

```
Your name: Administrador
Server name: server1
Username: admin
Password: [senha_segura]
```

### Passo 8: Instalação do SSH

```
✅ Install OpenSSH server
```

### Passo 9: Featured Server Snaps (Opcional)

```
[ ] Docker
[ ] Outros...
```

**Recomendação**: Não instale agora, instalaremos manualmente depois

### Passo 10: Instalação

- **Aguarde**: 10-20 minutos
- Após conclusão: **Reboot**

### Passo 11: Remover ISO

```bash
# No EVE-NG, via SSH:
cd /opt/unetlab/addons/qemu/linux-ubuntu-server-22/
mv cdrom.iso cdrom.iso.bak

# Ou delete:
rm cdrom.iso
```

**Reinicie o node** no EVE-NG para aplicar mudança

## ⚙️ Configuração Inicial

### Login Inicial

```
Username: admin
Password: [sua_senha]
```

### Atualizar Sistema

```bash
# Atualizar lista de pacotes
sudo apt update

# Atualizar pacotes instalados
sudo apt upgrade -y

# Limpar pacotes não utilizados
sudo apt autoremove -y
```

## 🌐 Configuração de Rede

### Verificar Interfaces

```bash
# Ver interfaces
ip addr show

# Ou
ip a
```

### Configurar IP Estático (Netplan)

```bash
# Editar configuração de rede
sudo nano /etc/netplan/00-installer-config.yaml
```

**💡 Dica**: Consulte [Comandos do Nano](referencia-comandos-nano.md) se precisar de ajuda com o editor.

**Conteúdo**:

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - 192.168.10.10/24
      routes:
        - to: default
          via: 192.168.10.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
    enp0s4:
      addresses:
        - 10.0.0.10/24
```

**Aplicar configuração**:

```bash

# Corrigir a permissão do arquivo
sudo chmod 600 /etc/netplan/00-installer-config.yaml

# Testar configuração
sudo netplan try

# Se OK, pressione Enter

# Ou aplicar diretamente
sudo netplan apply

# Verificar
ip addr show
```

### Configurar Hostname

```bash
# Ver hostname atual
hostname

# Alterar hostname
sudo hostnamectl set-hostname server1.lab.local

# Editar /etc/hosts
sudo nano /etc/hosts

# Adicionar:
# 127.0.1.1   server1.lab.local server1
```

## 🔐 Configurações de Segurança

### Configurar Firewall (UFW)

```bash
# Habilitar firewall
sudo ufw enable

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir HTTP
sudo ufw allow 80/tcp

# Permitir HTTPS
sudo ufw allow 443/tcp

# Ver status
sudo ufw status

# Ver regras numeradas
sudo ufw status numbered

# Deletar regra
sudo ufw delete [número]
```

### Configurar SSH

```bash
# Editar configuração SSH
sudo nano /etc/ssh/sshd_config

# Configurações recomendadas:
Port 22
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes

# Reiniciar SSH
sudo systemctl restart sshd
```

### Criar Usuário Adicional

```bash
# Criar usuário
sudo adduser usuario

# Adicionar ao grupo sudo
sudo usermod -aG sudo usuario

# Verificar
groups usuario
```

## 🛠️ Serviços Comuns

### 1. Servidor Web (Apache)

```bash
# Instalar Apache
sudo apt install apache2 -y

# Iniciar e habilitar
sudo systemctl start apache2
sudo systemctl enable apache2

# Verificar status
sudo systemctl status apache2

# Permitir no firewall
sudo ufw allow 'Apache Full'

# Testar
# No navegador: http://192.168.10.10
```

**Configuração básica**:

```bash
# Diretório web padrão
cd /var/www/html/

# Criar página teste
echo "<h1>Servidor Lab Funcionando!</h1>" | sudo tee index.html

# Ver logs
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log
```

### 2. Servidor DNS (BIND9)

```bash
# Instalar BIND9
sudo apt install bind9 bind9utils bind9-doc -y

# Configurar zona
sudo nano /etc/bind/named.conf.local

# Adicionar:
zone "lab.local" {
    type master;
    file "/etc/bind/db.lab.local";
};

# Criar arquivo de zona
sudo cp /etc/bind/db.local /etc/bind/db.lab.local
sudo nano /etc/bind/db.lab.local

# Editar conforme necessário

# Verificar configuração
sudo named-checkconf
sudo named-checkzone lab.local /etc/bind/db.lab.local

# Reiniciar
sudo systemctl restart bind9

# Permitir no firewall
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
```

### 3. Servidor DHCP (isc-dhcp-server)

```bash
# Instalar
sudo apt install isc-dhcp-server -y

# Configurar interface
sudo nano /etc/default/isc-dhcp-server

# Adicionar:
INTERFACESv4="enp0s4"

# Configurar DHCP
sudo nano /etc/dhcp/dhcpd.conf

# Exemplo de configuração:
subnet 10.0.0.0 netmask 255.255.255.0 {
    range 10.0.0.100 10.0.0.200;
    option routers 10.0.0.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option domain-name "lab.local";
    default-lease-time 600;
    max-lease-time 7200;
}

# Reiniciar
sudo systemctl restart isc-dhcp-server

# Ver status
sudo systemctl status isc-dhcp-server

# Ver leases
sudo dhcp-lease-list
# Ou
cat /var/lib/dhcp/dhcpd.leases
```

### 4. Servidor FTP (vsftpd)

```bash
# Instalar
sudo apt install vsftpd -y

# Backup da configuração original
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Editar configuração
sudo nano /etc/vsftpd.conf

# Configurações básicas:
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
ssl_enable=NO

# Reiniciar
sudo systemctl restart vsftpd

# Permitir no firewall
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp
```

### 5. Servidor SSH/SFTP (OpenSSH - já instalado)

```bash
# Já está instalado, configurar para SFTP
sudo nano /etc/ssh/sshd_config

# Adicionar ao final:
Match User sftpuser
    ForceCommand internal-sftp
    PasswordAuthentication yes
    ChrootDirectory /home/sftpuser
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no

# Criar usuário SFTP
sudo adduser sftpuser
sudo mkdir -p /home/sftpuser/uploads
sudo chown root:root /home/sftpuser
sudo chmod 755 /home/sftpuser
sudo chown sftpuser:sftpuser /home/sftpuser/uploads

# Reiniciar SSH
sudo systemctl restart sshd
```

## 📊 Monitoramento

### Comandos Úteis

```bash
# Ver uso de recursos
htop

# Ver espaço em disco
df -h

# Ver uso de memória
free -h

# Ver processos
ps aux

# Ver serviços
systemctl list-units --type=service

# Ver logs do sistema
sudo journalctl -xe
sudo journalctl -f

# Ver conexões de rede
ss -tuln
netstat -tuln

# Ver uso de rede
ifconfig
ip addr
```

### Instalar Ferramentas de Monitoramento

```bash
# Htop
sudo apt install htop -y

# Net-tools
sudo apt install net-tools -y

# Iotop (monitorar I/O)
sudo apt install iotop -y

# Nmap (scan de rede)
sudo apt install nmap -y
```

## 💾 Backup e Manutenção

### Backup Automático

```bash
# Criar script de backup
sudo nano /usr/local/bin/backup.sh
```

**Conteúdo**:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"
mkdir -p $BACKUP_DIR

# Backup de configurações importantes
tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
    /etc/apache2 \
    /etc/bind \
    /etc/dhcp \
    /var/www/html

# Manter apenas últimos 7 backups
find $BACKUP_DIR -name "config_*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $BACKUP_DIR/config_$DATE.tar.gz"
```

**Tornar executável**:

```bash
sudo chmod +x /usr/local/bin/backup.sh

# Testar
sudo /usr/local/bin/backup.sh

# Agendar no cron (diário às 3h)
sudo crontab -e

# Adicionar:
0 3 * * * /usr/local/bin/backup.sh
```

## 🔧 Troubleshooting

### Sem conectividade de rede

```bash
# Verificar interfaces
ip addr show

# Verificar rotas
ip route show

# Ping gateway
ping 192.168.10.1

# Verificar resolução DNS
nslookup google.com

# Verificar configuração netplan
sudo netplan --debug apply
```

### Serviço não inicia

```bash
# Ver status detalhado
sudo systemctl status apache2

# Ver logs
sudo journalctl -u apache2 -n 50

# Verificar configuração
sudo apache2ctl configtest

# Reiniciar serviço
sudo systemctl restart apache2
```

### Firewall bloqueando

```bash
# Ver regras
sudo ufw status verbose

# Desabilitar temporariamente (teste)
sudo ufw disable

# Reabilitar
sudo ufw enable
```

## ✅ Checklist de Configuração

- [ ] Sistema instalado e atualizado
- [ ] IP estático configurado
- [ ] Hostname configurado
- [ ] SSH funcionando
- [ ] Firewall configurado
- [ ] Serviços instalados e rodando
- [ ] Backup configurado
- [ ] Conectividade testada

## 🔄 Próximo Passo

Servidor configurado? Prossiga para:
➡️ [Configuração do Cliente Linux](09-configuracao-cliente-linux.md)

---

**Tempo Estimado**: 30-45 minutos  
**Dificuldade**: ⭐⭐⭐☆☆ (Média)
