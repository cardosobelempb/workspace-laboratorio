# ⚙️ Configuração Inicial do EVE-NG

## Visão Geral

Após a instalação, algumas configurações adicionais otimizarão seu EVE-NG para uso no laboratório.

## 🔐 Gerenciamento de Usuários

### Usuários Padrão

O EVE-NG vem com dois níveis de acesso:

| Usuário                  | Tipo           | Permissões                      |
| ------------------------ | -------------- | ------------------------------- |
| `admin`                  | Administrador  | Acesso total, gerenciar sistema |
| `user` (criado por você) | Usuário normal | Criar/editar próprios labs      |

### Criar Novo Usuário

1. **Via interface web**, faça login como `admin`

2. **Navegue para**:

   ```
   Ícone do usuário (canto superior direito) → Management → Users
   ```

3. **Clique em "Add User"**

4. **Preencha**:

   ```
   Username: aluno
   Name: Aluno de Laboratório
   Email: aluno@lab.local
   Password: [senha_segura]
   Role: User
   ```

5. **Clique em "Save"**

### Permissões de Usuários

- **Admin**: Pode ver todos os labs, gerenciar usuários, configurar sistema
- **User**: Pode criar e gerenciar apenas seus próprios labs

## 📁 Estrutura de Pastas

### Organizar Laboratories

1. **Na interface web**, clique em **"Add new folder"**

2. **Crie uma estrutura**:

   ```
   /
   ├── 01-Basico/
   ├── 02-Routing/
   ├── 03-Switching/
   ├── 04-Firewall/
   └── 99-Testes/
   ```

3. **Para cada pasta**:
   - Clique em "Add new folder"
   - Digite o nome
   - Clique em "Save"

### Mover Labs entre Pastas

- Clique com botão direito no lab
- Selecione "Move"
- Escolha a pasta de destino

## 🔌 Configurar Redes EVE-NG

### Tipos de Redes no EVE-NG

O EVE-NG possui redes especiais para conexão com o mundo externo:

| Rede        | Nome               | Função                        |
| ----------- | ------------------ | ----------------------------- |
| **pnet0**   | Management         | Conecta à rede física do host |
| **pnet1-9** | Bridges adicionais | Redes virtuais adicionais     |

### Cloud Networks (Redes Nuvem)

As "Cloud networks" conectam dispositivos do EVE-NG ao mundo externo.

**Tipos disponíveis**:

1. **Management (Cloud0)**:
   - Conecta à interface de gerenciamento (pnet0)
   - Acesso à internet e rede local

2. **NAT (Cloud1-9)**:
   - Redes bridge adicionais
   - Útil para separar tráfego

### Adicionar Interface Bridge (Opcional)

Para adicionar mais interfaces de rede à VM:

1. **No VMware**, desligue a VM EVE-NG

2. **Edit settings** → **Add** → **Network Adapter**

3. **Configure**:
   - Network connection: NAT (ou Bridged)
   - Clique em "OK"

4. **Inicie a VM**

5. **No console do EVE-NG**:

   ```bash
   # Configurar nova interface
   nano /etc/network/interfaces

   # Adicionar:
   auto pnet1
   iface pnet1 inet manual

   # Salvar (Ctrl+X, Y, Enter)

   # Reiniciar rede
   systemctl restart networking
   ```

## 🎨 Personalizar Interface

### Alterar Logo (Opcional)

1. **Via SSH no EVE-NG**:

   ```bash
   cd /opt/unetlab/html/themes/adminLTE/

   # Backup do logo original
   cp logo_small.png logo_small.png.bak

   # Adicionar seu logo personalizado
   # (upload via SCP ou similar)
   ```

### Configurar Tema

1. **Na interface web**, faça login

2. **Clique no ícone do usuário** → **My Account**

3. **Theme**: Selecione seu tema preferido
   - Default
   - Dark
   - Blue

4. **Clique em "Save"**

## ⚡ Otimizações de Performance

### Aumentar Recursos da VM

Se você tiver recursos disponíveis:

1. **Desligue a VM EVE-NG**

2. **No VMware**, Edit settings:
   - **RAM**: 16 GB (ou mais)
   - **CPU**: 6-8 cores
   - **Disco**: Expandir se necessário

3. **Inicie a VM**

### Habilitar UKSM (Memory Deduplication)

UKSM economiza RAM ao compartilhar páginas de memória idênticas:

```bash
# Via SSH no EVE-NG
echo 1 > /sys/kernel/mm/uksm/run

# Tornar permanente
echo "echo 1 > /sys/kernel/mm/uksm/run" >> /etc/rc.local
chmod +x /etc/rc.local
```

**Economia**: 30-50% de RAM em ambientes com múltiplos dispositivos similares

### Configurar Swap

Se tiver pouca RAM física:

```bash
# Verificar swap atual
swapon --show

# Criar arquivo de swap (8GB exemplo)
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Tornar permanente
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Ajustar swappiness (60 é padrão, 10 é menos agressivo)
echo 'vm.swappiness=10' >> /etc/sysctl.conf
sysctl -p
```

## 🔒 Segurança

### Alterar Porta SSH (Opcional)

```bash
# Editar configuração SSH
nano /etc/ssh/sshd_config

# Alterar linha:
# Port 22
# Para:
Port 2222

# Salvar e reiniciar
systemctl restart sshd
```

**Acesso**:

```bash
ssh -p 2222 root@192.168.1.100
```

### Configurar Firewall (ufw)

```bash
# Habilitar firewall
ufw enable

# Permitir SSH
ufw allow 22/tcp

# Permitir HTTP (interface web)
ufw allow 80/tcp

# Permitir consoles (telnet)
ufw allow 32768:65535/tcp

# Ver status
ufw status
```

### Backup de Configurações

```bash
# Backup automático de labs
# Criar script de backup
nano /root/backup-labs.sh
```

**Conteúdo do script**:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
mkdir -p $BACKUP_DIR

# Backup de labs
tar -czf $BACKUP_DIR/labs_$DATE.tar.gz /opt/unetlab/labs/

# Manter apenas últimos 7 backups
find $BACKUP_DIR -name "labs_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/labs_$DATE.tar.gz"
```

**Tornar executável e agendar**:

```bash
chmod +x /root/backup-labs.sh

# Adicionar ao cron (executar diariamente às 2h)
crontab -e

# Adicionar linha:
0 2 * * * /root/backup-labs.sh > /var/log/backup-labs.log 2>&1
```

## 📊 Monitoramento

### Ver Uso de Recursos

```bash
# CPU e RAM em tempo real
htop

# Espaço em disco
df -h

# Dispositivos em execução
virsh list --all

# Processos Docker (para alguns dispositivos)
docker ps

# Status dos serviços
systemctl status apache2 mysql docker
```

### Logs Importantes

```bash
# Logs do Apache (interface web)
tail -f /var/log/apache2/error.log

# Logs do sistema
journalctl -f

# Logs específicos do EVE-NG
tail -f /opt/unetlab/data/Logs/*
```

## 🌐 Configurações Avançadas de Rede

### Configurar IP Estático (se não fez na instalação)

```bash
# Editar configuração de rede
nano /etc/network/interfaces

# Configurar:
auto pnet0
iface pnet0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4

# Salvar e aplicar
systemctl restart networking

# Ou reiniciar
reboot
```

### Configurar Multiple IPs (Opcional)

Para ter múltiplos IPs na mesma interface:

```bash
nano /etc/network/interfaces

# Adicionar:
auto pnet0:1
iface pnet0:1 inet static
    address 192.168.1.101
    netmask 255.255.255.0

# Reiniciar rede
systemctl restart networking
```

## 🔧 Configurações do Servidor Web

### Aumentar Upload Limit

Para fazer upload de imagens grandes:

```bash
# Editar configuração PHP
nano /etc/php/8.1/apache2/php.ini

# Encontrar e alterar:
upload_max_filesize = 2G
post_max_size = 2G
max_execution_time = 3600
max_input_time = 3600

# Salvar e reiniciar Apache
systemctl restart apache2
```

### Habilitar HTTPS (Opcional)

```bash
# Instalar certificado autoassinado
apt install ssl-cert

# Habilitar módulo SSL
a2enmod ssl
a2ensite default-ssl

# Reiniciar Apache
systemctl restart apache2
```

**Acesso**:

```
https://192.168.1.100
```

⚠️ Você verá aviso de certificado não confiável (normal para autoassinado)

## ✅ Checklist de Configuração

- [ ] Senha do admin alterada
- [ ] Usuários adicionais criados (se necessário)
- [ ] Estrutura de pastas organizada
- [ ] Recursos da VM otimizados
- [ ] UKSM habilitado (economia de RAM)
- [ ] Backup configurado
- [ ] Firewall configurado (opcional)
- [ ] Upload limit aumentado
- [ ] Sistema atualizado

## 🎯 Testes de Funcionalidade

### Teste 1: Criar Lab de Teste

1. Crie um novo lab: "Teste-Config"
2. Abra o lab
3. Se a área de trabalho aparecer → ✅

### Teste 2: Verificar Recursos

```bash
# Via SSH
free -h    # RAM disponível
df -h      # Disco disponível
uptime     # Load average
```

### Teste 3: Verificar Conectividade

```bash
# Ping para internet
ping -c 4 8.8.8.8

# Resolução DNS
nslookup google.com
```

## 🔄 Próximo Passo

EVE-NG configurado? Prossiga para adicionar imagens de dispositivos:
➡️ [Adicionar Imagens ao EVE-NG](06-adicionar-imagens.md)

---

**Tempo Estimado**: 15-20 minutos  
**Dificuldade**: ⭐⭐☆☆☆ (Fácil-Média)
