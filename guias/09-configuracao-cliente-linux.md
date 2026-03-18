# 🖥️ Configuração do Cliente Linux

## Visão Geral

O cliente Linux simula uma estação de trabalho em sua rede de laboratório. Usaremos Lubuntu (Ubuntu com interface LXDE) para economizar recursos.

## 🚀 Adicionar Cliente ao Lab

### Passo 1: Adicionar Node

1. **No EVE-NG**, abra seu lab

2. **Adicione novo node**:
   - Node type: **QEMU**
   - Template: **Linux** (sua distribuição desktop)
   - Name: `Client-1`
   - RAM: `2048 MB` (mínimo), `4096 MB` (fluido)
   - CPU: `2`
   - Ethernet interfaces: `1`

3. **Clique em "Save"**

### Passo 2: Iniciar e Instalar

1. **Inicie o node**

2. **Conecte ao console**

3. **Boot do installer** (Lubuntu/Ubuntu Desktop)

## 💿 Instalação do Lubuntu/Ubuntu Desktop

### Instalação Gráfica

1. **Try or Install Lubuntu**

2. **Idioma**: Selecione Português do Brasil (ou preferência)

3. **Instalar Lubuntu**

4. **Teclado**: Brazilian (ABNT2)

5. **Atualizações e Software**:
   - [ ] Download updates (desmarque para instalar mais rápido)
   - [ ] Install third-party software (opcional)

6. **Tipo de Instalação**:
   - **Apagar disco e instalar Lubuntu** (seguro, é uma VM)

7. **Fuso Horário**: São Paulo (ou sua cidade)

8. **Usuário**:

   ```
   Seu nome: Cliente Lab
   Nome do computador: client1
   Nome de usuário: user
   Senha: [senha_simples_para_lab]
   ```

9. **Instalar**: Aguarde 10-20 minutos

10. **Reiniciar**

### Pós-Instalação

1. **Login**: user / [sua_senha]

2. **Remover ISO** (no EVE-NG):
   ```bash
   # Via SSH no EVE-NG
   cd /opt/unetlab/addons/qemu/linux-lubuntu-22/
   rm cdrom.iso
   ```

## ⚙️ Configuração Inicial

### Atualizar Sistema

```bash
# Abrir terminal (Ctrl+Alt+T)
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

### Instalar Ferramentas Úteis

```bash
# Ferramentas de rede
sudo apt install net-tools iputils-ping traceroute nmap -y

# Navegador adicional
sudo apt install firefox -y

# Editor de texto
sudo apt install gedit -y

# Cliente SSH
sudo apt install openssh-client -y

# Cliente FTP
sudo apt install filezilla -y

# Wireshark (captura de pacotes)
sudo apt install wireshark -y
# Durante instalação, permitir usuários não-root usar wireshark: Yes
sudo usermod -aG wireshark $USER
```

## 🌐 Configuração de Rede

### Método 1: Interface Gráfica (Fácil)

1. **Clique no ícone de rede** (canto inferior direito)

2. **Edit Connections**

3. **Selecione a conexão** (Wired connection 1)

4. **Editar**

5. **Aba IPv4 Settings**:

   ```
   Method: Manual

   Address: 192.168.10.100
   Netmask: 255.255.255.0
   Gateway: 192.168.10.1

   DNS servers: 8.8.8.8, 8.8.4.4
   ```

6. **Salvar**

7. **Desconectar e reconectar** a rede

### Método 2: Via Terminal (Netplan)

```bash
# Ver interfaces
ip addr show

# Editar netplan
sudo nano /etc/netplan/01-network-manager-all.yaml

# Conteúdo:
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.10.100/24
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
ping 8.8.8.8
```

### Método 3: DHCP (Automático)

Se há servidor DHCP na rede:

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: yes
```

## 🔧 Ferramentas de Diagnóstico

### Testar Conectividade

```bash
# Ping para gateway
ping -c 4 192.168.10.1

# Ping para internet
ping -c 4 8.8.8.8
ping -c 4 google.com

# Traceroute
traceroute google.com

# Ver rotas
ip route show

# Ver DNS
cat /etc/resolv.conf

# Testar porta
telnet 192.168.10.10 80
# Ou
nc -zv 192.168.10.10 80
```

### Captura de Pacotes (Wireshark)

```bash
# Abrir Wireshark
sudo wireshark

# Ou na linha de comando
sudo tcpdump -i enp0s3

# Capturar para arquivo
sudo tcpdump -i enp0s3 -w captura.pcap

# Ler arquivo
tcpdump -r captura.pcap
```

### Scan de Rede

```bash
# Descobrir hosts ativos
nmap -sn 192.168.10.0/24

# Scan de portas
nmap 192.168.10.10

# Scan detalhado
nmap -A 192.168.10.10

# Scan rápido
nmap -F 192.168.10.10
```

## 🌐 Navegação e Testes Web

### Testar Servidor Web

1. **Abrir navegador** (Firefox ou Chrome)

2. **Acessar**:

   ```
   http://192.168.10.10
   ```

3. **Ver resposta** do servidor

### Testar DNS

```bash
# nslookup
nslookup google.com
nslookup google.com 8.8.8.8

# dig
dig google.com

# host
host google.com
```

## 📁 Transferência de Arquivos

### Via FTP (FileZilla)

1. **Abrir FileZilla**

2. **Conectar**:

   ```
   Host: 192.168.10.10
   Username: [user]
   Password: [pass]
   Port: 21
   ```

3. **Transferir arquivos** (arrastar e soltar)

### Via SCP/SFTP (Terminal)

```bash
# Upload de arquivo
scp arquivo.txt user@192.168.10.10:/home/user/

# Download de arquivo
scp user@192.168.10.10:/home/user/arquivo.txt .

# SFTP interativo
sftp user@192.168.10.10
```

### Via SSH

```bash
# Conectar via SSH
ssh user@192.168.10.10

# SSH com porta diferente
ssh -p 2222 user@192.168.10.10

# Executar comando remoto
ssh user@192.168.10.10 'ls -la'
```

## 🎯 Cenários de Teste Comuns

### Teste 1: Conectividade Básica

```bash
#!/bin/bash
echo "=== Teste de Conectividade ==="

echo "1. Gateway:"
ping -c 2 192.168.10.1

echo "2. Servidor Local:"
ping -c 2 192.168.10.10

echo "3. DNS Externo:"
ping -c 2 8.8.8.8

echo "4. Resolução DNS:"
ping -c 2 google.com

echo "=== Teste Concluído ==="
```

### Teste 2: Serviços

```bash
#!/bin/bash
echo "=== Teste de Serviços ==="

echo "Web Server:"
curl -I http://192.168.10.10

echo "SSH:"
nc -zv 192.168.10.10 22

echo "DNS:"
nslookup google.com 192.168.10.10

echo "=== Teste Concluído ==="
```

### Teste 3: Performance de Rede

```bash
# iperf3 (instalar se necessário)
sudo apt install iperf3 -y

# No servidor:
iperf3 -s

# No cliente:
iperf3 -c 192.168.10.10
```

## 🔒 Configurações Adicionais

### Firewall (UFW)

```bash
# Habilitar firewall
sudo ufw enable

# Permitir SSH saindo (cliente)
sudo ufw allow out 22/tcp

# Ver status
sudo ufw status
```

### Proxy (se necessário)

```bash
# Configurar proxy no terminal
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"

# Tornar permanente
echo 'export http_proxy="http://proxy.example.com:8080"' >> ~/.bashrc
echo 'export https_proxy="http://proxy.example.com:8080"' >> ~/.bashrc
```

### Hosts Personalizados

```bash
# Editar hosts
sudo nano /etc/hosts

# Adicionar:
192.168.10.10   server1.lab.local server1
192.168.10.1    router.lab.local router

# Testar
ping server1
```

## 🎨 Personalização (Opcional)

### Alterar Tema

1. **Preferences** → **LXQt Configuration** → **Appearance**
2. Escolha tema escuro ou claro

### Configurar Papel de Parede

1. Botão direito na área de trabalho
2. **Desktop Preferences**
3. Escolha imagem ou cor

### Atalhos Úteis

```
Ctrl+Alt+T      - Abrir terminal
Ctrl+Alt+L      - Bloquear tela
Alt+F4          - Fechar janela
Alt+Tab         - Trocar entre janelas
```

## 📊 Monitoramento

### Ver Recursos

```bash
# CPU e RAM
htop

# Espaço em disco
df -h

# Uso de rede em tempo real
sudo iftop

# Conexões ativas
netstat -an
ss -tuln
```

## 🔧 Troubleshooting

### Sem rede

```bash
# Verificar interface
ip addr show

# Interface está "UP"?
sudo ip link set enp0s3 up

# Verificar cabo (no EVE-NG)
# Certifique-se que o cabo está conectado

# Reiniciar NetworkManager
sudo systemctl restart NetworkManager
```

### DNS não resolve

```bash
# Verificar resolv.conf
cat /etc/resolv.conf

# Deve conter nameservers

# Testar DNS manualmente
nslookup google.com 8.8.8.8

# Se funciona, problema é DNS local
```

### Interface gráfica lenta

```bash
# Aumentar RAM da VM (no VMware/EVE-NG)
# Recomendado: 4GB para desktop

# Ou use versão mais leve (XFCE, LXDE)
```

## ✅ Checklist de Configuração

- [ ] Sistema instalado e atualizado
- [ ] Ferramentas de rede instaladas
- [ ] IP configurado (estático ou DHCP)
- [ ] Conectividade testada (gateway, internet, DNS)
- [ ] Navegador funcionando
- [ ] SSH cliente configurado
- [ ] Ferramentas de diagnóstico testadas
- [ ] Wireshark funcionando

## 🎓 Exercícios Práticos

1. **Ping Test**: Ping todos os dispositivos da rede
2. **Web Test**: Acessar servidor web local
3. **SSH Test**: Conectar via SSH ao servidor
4. **FTP Test**: Transferir arquivos via FTP
5. **Capture Test**: Capturar pacotes com Wireshark
6. **Nmap Test**: Fazer scan da rede
7. **Traceroute**: Traçar rota até internet

## 🔄 Próximo Passo

Cliente configurado? Aprenda a criar topologias complexas:
➡️ [Criando sua Primeira Topologia](10-primeira-topologia.md)

---

**Tempo Estimado**: 30-40 minutos  
**Dificuldade**: ⭐⭐☆☆☆ (Fácil-Média)
