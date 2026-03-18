# 🗺️ Criando sua Primeira Topologia

## Visão Geral

Neste guia, você aprenderá a criar uma topologia básica no EVE-NG conectando MikroTik, servidor e cliente Linux.

## 🎯 Topologia que Criaremos

```
                    Internet (Cloud0)
                           |
                    [Router MikroTik]
                      /         \
                     /           \
              [Servidor]      [Cliente]
           192.168.10.10   192.168.10.100
```

**Funcionalidades**:

- Router fornece acesso à internet via NAT
- Servidor web acessível pelo cliente
- Rede interna: 192.168.10.0/24

## 📝 Passo a Passo

### Passo 1: Criar Novo Lab

1. **Acesse EVE-NG** via navegador
2. **Clique em "Add new lab"**
3. **Preencha**:
   ```
   Name: Topologia-Basica
   Version: 1.0
   Author: Seu Nome
   Description: Topologia básica com router, servidor e cliente
   ```
4. **Clique em "Save"**
5. **Abra o lab** (clique nele)

### Passo 2: Adicionar Router MikroTik

1. **Clique no ícone "+" na barra lateral** ou botão direito → "Add node"

2. **Configurações**:

   ```
   Node type: Qemu
   Template: MikroTik CHR
   Name: Router-1
   Icon: Router (azul)
   RAM: 256 MB
   CPU: 1
   Ethernet interfaces: 3
   ```

3. **Clique em "Save"**

4. **Posicione** o router no topo da área de trabalho

### Passo 3: Adicionar Servidor Linux

1. **Adicionar novo node**

2. **Configurações**:

   ```
   Node type: Qemu
   Template: Linux Ubuntu Server
   Name: Server-1
   Icon: Server
   RAM: 2048 MB
   CPU: 2
   Ethernet interfaces: 1
   ```

3. **Clique em "Save"**

4. **Posicione** no lado esquerdo inferior

### Passo 4: Adicionar Cliente Linux

1. **Adicionar novo node**

2. **Configurações**:

   ```
   Node type: Qemu
   Template: Linux Desktop
   Name: Client-1
   Icon: Desktop
   RAM: 2048 MB
   CPU: 2
   Ethernet interfaces: 1
   ```

3. **Clique em "Save"**

4. **Posicione** no lado direito inferior

### Passo 5: Adicionar Network (Switch Virtual)

1. **Clique no ícone de rede** na barra lateral

2. **Selecione "Network"**

3. **Configurações**:

   ```
   Type: Network
   Name: Net-LAN
   ```

4. **Clique em "Save"**

5. **Posicione** entre os dispositivos

### Passo 6: Adicionar Cloud (Acesso Externo)

1. **Adicionar node**

2. **Selecione "Network" → "Cloud"**

3. **Configurações**:

   ```
   Name: Cloud-Internet
   Type: pnet0 (Management)
   ```

4. **Clique em "Save"**

5. **Posicione** acima do router

## 🔌 Conectar Dispositivos

### Conexão 1: Router → Internet (Cloud)

1. **Passe o mouse** sobre o **Cloud-Internet**
2. **Clique no ícone de cabo** (ou arraste)
3. **Interface**: Selecione "pnet0"
4. **Conecte ao Router-1**
5. **Interface do Router**: ether1

### Conexão 2: Router → Network (LAN)

1. **Do Router-1**, interface **ether2**
2. **Para Net-LAN**

### Conexão 3: Server → Network (LAN)

1. **Do Server-1**, interface **enp0s3** (ou eth0)
2. **Para Net-LAN**

### Conexão 4: Client → Network (LAN)

1. **Do Client-1**, interface **enp0s3**
2. **Para Net-LAN**

**Resultado**: Todos os dispositivos na LAN conectados através de Net-LAN

## 🚀 Iniciar Dispositivos

### Iniciar Todos de Uma Vez

1. **Selecione todos** os dispositivos:
   - Ctrl + A (selecionar tudo)
   - Ou arraste uma caixa ao redor

2. **Botão direito** → **Start**

3. **Aguarde** inicialização (1-2 minutos)

### Iniciar Individualmente

1. **Botão direito** no dispositivo
2. **Start**

**Ordem recomendada**:

1. Router (primeiro)
2. Server
3. Client

## ⚙️ Configurar Dispositivos

### Configurar Router MikroTik

1. **Console** no Router-1 (botão direito → Console)

2. **Login**: `admin` (sem senha inicial)

3. **Configuração rápida**:

```routeros
# Definir senha
/user set admin password=admin123

# Nome do router
/system identity set name=Router-Lab

# IP na interface WAN (ether1) - DHCP do seu host
/ip dhcp-client add interface=ether1 disabled=no

# IP na interface LAN (ether2)
/ip address add address=192.168.10.1/24 interface=ether2

# DNS
/ip dns set servers=8.8.8.8,8.8.4.4 allow-remote-requests=yes

# NAT para internet
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Firewall básico
/ip firewall filter add chain=input connection-state=established,related action=accept
/ip firewall filter add chain=input protocol=icmp action=accept
/ip firewall filter add chain=input in-interface=ether2 action=accept
/ip firewall filter add chain=input action=drop

# DHCP Server na LAN (opcional)
/ip pool add name=dhcp_pool ranges=192.168.10.50-192.168.10.150
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8
/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool disabled=no

# Salvar
/system backup save name=config-inicial
```

### Configurar Servidor (IP Estático)

1. **Console** no Server-1

2. **Login** com suas credenciais

3. **Configurar rede**:

```bash
# Editar netplan
sudo nano /etc/netplan/00-installer-config.yaml

# Conteúdo:
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

# Aplicar
sudo netplan apply

# Verificar
ip addr show
ping 192.168.10.1
ping 8.8.8.8
```

### Configurar Cliente (DHCP ou Estático)

**Opção 1: DHCP (se configurou no router)**

```bash
# O cliente já deve ter recebido IP automaticamente
ip addr show

# Verificar
ping 192.168.10.1
ping 192.168.10.10
```

**Opção 2: IP Estático**

```bash
# Similar ao servidor
sudo nano /etc/netplan/01-network-manager-all.yaml

# Conteúdo:
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - 192.168.10.100/24
      routes:
        - to: default
          via: 192.168.10.1
      nameservers:
        addresses:
          - 8.8.8.8

# Aplicar
sudo netplan apply
```

## ✅ Testar Conectividade

### Teste 1: Do Cliente para Router

```bash
# No Cliente
ping -c 4 192.168.10.1
```

**Esperado**: ✅ 4 pacotes enviados, 4 recebidos, 0% perda

### Teste 2: Do Cliente para Servidor

```bash
# No Cliente
ping -c 4 192.168.10.10
```

**Esperado**: ✅ Resposta do servidor

### Teste 3: Do Cliente para Internet

```bash
# No Cliente
ping -c 4 8.8.8.8
ping -c 4 google.com
```

**Esperado**: ✅ Acesso à internet funcionando

### Teste 4: Resolução DNS

```bash
# No Cliente
nslookup google.com
```

**Esperado**: ✅ Resolução bem-sucedida

### Teste 5: HTTP

```bash
# No Servidor, instalar Apache
sudo apt install apache2 -y

# No Cliente, testar
curl http://192.168.10.10
# Ou abrir navegador: http://192.168.10.10
```

**Esperado**: ✅ Página web do Apache

## 💾 Salvar Lab

### Auto-Save

O EVE-NG salva automaticamente as alterações na topologia.

### Exportar Lab (Backup)

1. **Via SSH no EVE-NG**:

```bash
# Backup do lab específico
cd /opt/unetlab/labs/
tar -czf /tmp/Topologia-Basica.tar.gz Topologia-Basica.unl

# Download via SCP (no seu computador)
scp root@192.168.1.100:/tmp/Topologia-Basica.tar.gz .
```

## 📸 Snapshot (Backup de Estado)

### Salvar Estado dos Dispositivos

1. **No EVE-NG**, botão direito em um dispositivo

2. **Stop** o dispositivo

3. **No VMware**, encontre a VM do dispositivo:
   - VMs EVE-NG ficam em: `/opt/unetlab/tmp/`

4. **Usar QCOW2 snapshot** (avançado):

```bash
# Via SSH no EVE-NG
/opt/qemu/bin/qemu-img snapshot -c snapshot1 [caminho-disco].qcow2
```

## 🎨 Organizar Topologia

### Adicionar Textos e Formas

1. **Botão direito** na área de trabalho → **Add text**

2. **Digite**: "Rede Interna - 192.168.10.0/24"

3. **Posicione** próximo à network

### Adicionar Imagens (Opcional)

1. **Botão direito** → **Add picture**

2. **Upload** de imagem ou use URL

3. **Útil para**: Logos, diagramas, notas visuais

### Cores de Cabos

- **Cores disponíveis** diferenciam propósitos
- **Dica**: Use cores consistentes (ex: vermelho = WAN, azul = LAN)

## 🔄 Gerenciar Lab

### Parar Todos os Dispositivos

1. **Selecionar todos**: Ctrl + A

2. **Botão direito** → **Stop**

### Wipe (Limpar Configuração)

⚠️ **CUIDADO**: Apaga todas as configurações!

1. **Parar dispositivo**

2. **Botão direito** → **Wipe**

3. **Confirmar**

**Resultado**: Dispositivo volta ao estado inicial (como recém-adicionado)

### Exportar/Importar Lab

**Exportar**:

```bash
# Labs ficam em:
/opt/unetlab/labs/[nome-lab].unl
```

**Importar**:

1. Upload do arquivo .unl
2. Colocar em `/opt/unetlab/labs/`
3. Ajustar permissões: `/opt/unetlab/wrappers/unl_wrapper -a fixpermissions`

## 📊 Monitorar Lab

### Ver Status dos Dispositivos

- **Verde**: Rodando
- **Vermelho**: Parado
- **Amarelo**: Iniciando

### Ver Uso de Recursos (EVE-NG)

```bash
# Via SSH no EVE-NG
htop

# Ver VMs rodando
virsh list --all
```

## ✅ Checklist

- [ ] Lab criado com nome descritivo
- [ ] Router adicionado e posicionado
- [ ] Servidor adicionado
- [ ] Cliente adicionado
- [ ] Network (switch) adicionada
- [ ] Cloud adicionado (acesso externo)
- [ ] Todos os cabos conectados corretamente
- [ ] Dispositivos iniciados
- [ ] IPs configurados
- [ ] Conectividade testada (ping, web)
- [ ] Lab salvo

## 🎓 Exercícios Extras

1. **Adicionar mais um cliente** e testar conectividade
2. **Criar VLAN** no MikroTik e separar tráfego
3. **Adicionar segundo router** e configurar roteamento entre redes
4. **Capturar tráfego** com Wireshark no cliente
5. **Configurar VPN** entre dois sites

## 🔄 Próximo Passo

Topologia funcionando? Aprenda técnicas avançadas:
➡️ [Conectando Dispositivos Avançado](11-conectando-dispositivos.md)

---

**Tempo Estimado**: 30-45 minutos  
**Dificuldade**: ⭐⭐⭐☆☆ (Média)
