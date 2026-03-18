# 🌐 Instalação do EVE-NG

## Visão Geral

O EVE-NG (Emulated Virtual Environment - Next Generation) é a plataforma onde você criará e executará suas topologias de rede. Ele roda como uma VM dentro do VMware Workstation.

## O que é EVE-NG?

EVE-NG é um emulador de rede multi-vendor que permite:

- ✅ Criar topologias de rede complexas
- ✅ Emular roteadores, switches, firewalls
- ✅ Conectar dispositivos virtuais
- ✅ Gerenciar tudo via interface web

## Pré-requisitos

- ✅ VMware Workstation instalado e funcionando
- ✅ Arquivo EVE-NG OVA baixado
- ✅ Mínimo 8 GB RAM disponível
- ✅ 50 GB de espaço livre em disco

## 📦 Importar o OVA para VMware

### Passo 1: Iniciar Importação

1. **Abra o VMware Workstation**

2. **Importar OVA**:
   ```
   File → Open
   ```
3. **Selecione o arquivo**:

   ```
   EVE-Community-latest.ova
   ```

4. **Clique em "Open"**

### Passo 2: Configurar Nome e Localização

1. **Nome da VM**:

   ```
   EVE-NG
   ```

2. **Localização** (recomendado):

   ```
   C:\VMs\EVE-NG\
   ```

3. Clique em **"Import"**

4. **Aguarde a importação**:
   - ⏱️ Tempo: 5-10 minutos
   - A VM será criada e configurada automaticamente

### Passo 3: Ajustar Configurações da VM

1. **Selecione a VM** "EVE-NG" na biblioteca

2. **Clique em "Edit virtual machine settings"**

3. **Configurações Recomendadas**:

   **Memória (Memory)**:

   ```
   Mínimo: 4 GB (4096 MB)
   Recomendado: 8 GB (8192 MB)
   Ideal: 16 GB (16384 MB)
   ```

   **Processadores (Processors)**:

   ```
   Number of processors: 1
   Number of cores per processor: 4

   OU

   Number of processors: 2
   Number of cores per processor: 2
   ```

   **Habilitar Virtualização Aninhada**:
   - ✅ Marque "Virtualize Intel VT-x/EPT or AMD-V/RVI"
   - ⚠️ **MUITO IMPORTANTE** para dispositivos executarem corretamente

   **Disco Rígido**:

   ```
   Padrão: 50 GB (suficiente para começar)
   Se precisar expandir depois: 100-200 GB
   ```

   **Rede (Network Adapter)**:

   ```
   Network connection: Bridged (Modo Ponte)
   ```

   **OU**, se preferir isolamento:

   ```
   Network connection: NAT
   ```

4. **Clique em "OK"** para salvar

## 🚀 Primeira Inicialização

### Passo 1: Iniciar a VM

1. **Selecione a VM** "EVE-NG"

2. **Clique em "Power On"** (Ligar)

3. **Aguarde o boot**:
   - ⏱️ Tempo: 1-2 minutos
   - Você verá o console do Linux inicializando

### Passo 2: Login Inicial

1. **Tela de Login**:

   ```
   EVE-NG login: root
   Password: eve
   ```

2. **Pressione Enter**

### Passo 3: Configuração Inicial (Root Password)

1. **Alterar senha do root**:

   ```
   Old password: eve
   New password: [sua_senha_segura]
   Retype password: [sua_senha_segura]
   ```

   **Dica**: Use uma senha forte que você lembrará!

## ⚙️ Configuração de Rede

### Passo 1: Configurar Hostname

```
Enter new hostname: eve-ng
```

### Passo 2: Configurar Domínio (opcional)

```
Enter new domain name: lab.local
```

**Ou pressione Enter para manter o padrão**

### Passo 3: Configurar IP

Você tem duas opções:

#### Opção A: DHCP (Mais Fácil)

```
Configure management interface [no,yes,dhcp] ? dhcp
```

- ✅ Recomendado para começar rapidamente
- O EVE-NG receberá IP automaticamente
- Anote o IP mostrado na tela

#### Opção B: IP Estático (Recomendado para Produção)

```
Configure management interface [no,yes,dhcp] ? yes

Static IP address [127.0.0.1]: 192.168.1.100
Netmask [255.255.255.0]: 255.255.255.0
Default gateway [192.168.1.1]: 192.168.1.1
Primary DNS [8.8.8.8]: 8.8.8.8
Secondary DNS [8.8.4.4]: 8.8.4.4
```

**Adapte os valores para sua rede!**

### Passo 4: Configurar Proxy (se necessário)

```
Configure Proxy [no,yes] ? no
```

**Pressione Enter** (a menos que sua rede use proxy)

### Passo 5: Aplicar Configurações

```
Direct connection or SSH session? direct
```

**Pressione Enter**

**Aguarde**:

- O sistema aplicará as configurações
- Serviços serão reiniciados
- ⏱️ Tempo: 30-60 segundos

### Passo 6: Anotar Informações

Após configuração, o sistema mostrará:

```
EVE-NG is now configured!

Access the Web Interface:
http://192.168.1.100

SSH Access:
ssh root@192.168.1.100

---
Username: admin
Password: eve
---
```

**⚠️ IMPORTANTE**: Anote o IP do EVE-NG!

## 🌐 Acessar Interface Web

### Passo 1: Abrir Navegador

1. No seu computador (não na VM), abra um navegador

2. **Navegadores Recomendados**:
   - Google Chrome (melhor compatibilidade)
   - Microsoft Edge
   - Firefox

### Passo 2: Acessar EVE-NG

1. **Digite o endereço**:

   ```
   http://192.168.1.100
   ```

   (use o IP do seu EVE-NG)

2. **Tela de Login**:

   ```
   Username: admin
   Password: eve
   ```

3. **Clique em "Login"**

### Passo 3: Alterar Senha do Admin (Recomendado)

1. No canto superior direito, clique no ícone do usuário

2. Selecione "Change Password"

3. Digite:

   ```
   Old password: eve
   New password: [sua_senha_admin]
   Confirm password: [sua_senha_admin]
   ```

4. Clique em "Save"

## 🔧 Configuração Pós-Instalação

### Atualizar Sistema (Recomendado)

1. **Via SSH** (ou console da VM):

   ```bash
   # Login como root
   ssh root@192.168.1.100

   # Atualizar repositórios
   apt update

   # Atualizar pacotes
   apt upgrade -y

   # Reiniciar se necessário
   reboot
   ```

2. **Aguarde**:
   - ⏱️ Tempo: 5-15 minutos (dependendo de atualizações)

### Instalar EVE-NG Client Integration

Para melhor integração com seu desktop:

1. **Baixe o Client Pack**:
   - 🌐 https://www.eve-ng.net/index.php/download/
   - Escolha versão para seu SO (Windows/Linux/Mac)

2. **Instale o Client Pack**:
   - Execute o instalador
   - Siga as instruções padrão

3. **Benefícios**:
   - Abertura automática de consoles
   - Integração com Wireshark
   - Melhor experiência de uso

### Verificar Status dos Serviços

```bash
# Via SSH no EVE-NG
systemctl status apache2
systemctl status mysql
systemctl status docker
```

Todos devem estar **active (running)** ✅

## 🧪 Teste de Funcionamento

### Criar Laboratório de Teste

1. **Na interface web**, clique em **"Add new lab"**

2. **Configurações**:

   ```
   Name: Teste
   Version: 1
   Author: Seu Nome
   Description: Laboratório de teste
   ```

3. **Clique em "Save"**

4. **Abra o lab**: Clique em "Teste"

5. **Você verá**:
   - Área de trabalho em branco
   - Barra de ferramentas no lado esquerdo
   - ✅ Se tudo apareceu, EVE-NG está funcionando!

## 🔧 Troubleshooting

### Não consigo acessar a interface web

**Verificações**:

1. **VM está ligada?**
   - No VMware, verifique se VM está "Powered On"

2. **Ping no IP do EVE-NG**:

   ```cmd
   ping 192.168.1.100
   ```

   - Se não responde, problema de rede

3. **Firewall bloqueando?**:
   - Temporariamente desabilite firewall para teste

4. **IP correto?**:
   - No console da VM, execute:
     ```bash
     ip addr show
     ```
   - Verifique o IP em "pnet0"

### Erro: "CPU does not support VT-x"

**Solução**:

1. Desligue a VM
2. Edit settings → Processors
3. ✅ Marque "Virtualize Intel VT-x/EPT or AMD-V/RVI"
4. Ligue a VM novamente

### Serviços não iniciam

```bash
# Reiniciar serviços manualmente
systemctl restart apache2
systemctl restart mysql
systemctl restart docker

# Verificar logs
journalctl -xe
```

### Interface web lenta

**Soluções**:

- Aumente RAM da VM (mínimo 8 GB)
- Use navegador Chrome
- Feche abas/programas desnecessários

## ✅ Checklist de Verificação

- [ ] VM EVE-NG importada no VMware
- [ ] RAM configurada (mínimo 8 GB)
- [ ] Virtualização aninhada habilitada
- [ ] VM iniciada com sucesso
- [ ] Senha do root alterada
- [ ] Rede configurada (DHCP ou estático)
- [ ] IP do EVE-NG anotado
- [ ] Interface web acessível
- [ ] Senha do admin alterada
- [ ] Sistema atualizado
- [ ] Lab de teste criado com sucesso

## 📊 Informações Importantes

### Credenciais Padrão

| Acesso                    | Usuário | Senha Padrão |
| ------------------------- | ------- | ------------ |
| **Console/SSH (root)**    | `root`  | `eve`        |
| **Web Interface (admin)** | `admin` | `eve`        |

**⚠️ ALTERE AS SENHAS PADRÃO!**

### Portas Utilizadas

| Serviço              | Porta  |
| -------------------- | ------ |
| HTTP (Web Interface) | 80     |
| SSH                  | 22     |
| Telnet para consoles | 32768+ |

### Comandos Úteis

```bash
# Ver IP da VM
ip addr show

# Reiniciar serviços web
systemctl restart apache2

# Ver espaço em disco
df -h

# Ver uso de RAM
free -h

# Reiniciar EVE-NG
reboot
```

## 🔄 Próximo Passo

EVE-NG instalado e funcionando? Prossiga para:
➡️ [Configuração Inicial do EVE-NG](05-configuracao-inicial-eve-ng.md)

---

**Tempo Estimado**: 30-45 minutos  
**Dificuldade**: ⭐⭐⭐☆☆ (Média)
