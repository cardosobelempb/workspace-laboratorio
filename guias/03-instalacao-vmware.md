# 🖥️ Instalação do VMware Workstation

## Visão Geral

O VMware Workstation é a plataforma de virtualização base onde o EVE-NG será executado. Este guia cobre a instalação completa no Windows.

## Pré-requisitos

Antes de iniciar, certifique-se de que:

- ✅ Virtualização está habilitada na BIOS
- ✅ Hyper-V está desabilitado (Windows)
- ✅ Você tem permissões de administrador
- ✅ Arquivo de instalação do VMware foi baixado

## 📦 Instalação no Windows

### Passo 1: Executar o Instalador

1. **Localize o arquivo**:

   ```
   VMware-workstation-full-17.x.x-xxxxx.exe
   ```

2. **Clique com botão direito** → "Executar como administrador"

3. **Controle de Conta de Usuário (UAC)**:
   - Clique em "Sim" para permitir alterações

### Passo 2: Assistente de Instalação

1. **Tela de Boas-vindas**:
   - Clique em **"Next"** (Próximo)

2. **Contrato de Licença**:
   - Marque "I accept the terms in the License Agreement"
   - Clique em **"Next"**

3. **Tipo de Instalação Personalizada**:
   - ✅ **Recomendado**: Deixe as opções padrão
   - Opções disponíveis:
     - [ ] Enhanced Keyboard Driver (driver de teclado melhorado)
     - [ ] Add VMware Workstation console tools to PATH
   - Clique em **"Next"**

4. **Experiência do Usuário**:
   - [ ] Check for product updates on startup (opcional)
   - [ ] Join VMware Customer Experience Improvement Program (opcional)
   - Clique em **"Next"**

5. **Atalhos**:
   - ✅ Desktop (Área de Trabalho)
   - ✅ Start Menu Programs Folder (Menu Iniciar)
   - Clique em **"Next"**

6. **Pronto para Instalar**:
   - Revise as configurações
   - Clique em **"Install"** (Instalar)

### Passo 3: Aguardar Instalação

- ⏱️ Tempo estimado: 5-10 minutos
- A instalação irá:
  - Copiar arquivos
  - Instalar drivers de rede virtual
  - Configurar serviços

**Drivers de Rede Virtual Instalados**:

- VMnet0 (Bridged - Modo Ponte)
- VMnet1 (Host-only - Somente Host)
- VMnet8 (NAT - Network Address Translation)

### Passo 4: Finalização

1. **Instalação Completa**:
   - Clique em **"Finish"** (Concluir)
   - Marque "Launch VMware Workstation" para abrir

2. **Reinicialização** (se solicitado):
   - Salve todos os trabalhos abertos
   - Reinicie o computador

## 🔑 Ativação da Licença

### Opção 1: Trial (Avaliação)

1. Ao abrir o VMware Workstation pela primeira vez:
   - Selecione "Use VMware Workstation 17 for **30 days**"
   - Clique em "Continue"

### Opção 2: Licença Completa

1. Selecione "I have a license key for VMware Workstation 17"
2. Digite sua chave de licença:
   ```
   XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
   ```
3. Clique em "Continue"

### Opção 3: VMware Workstation Player (Gratuito)

Se estiver usando o Player:

- Selecione "Use VMware Workstation 17 Player for free for non-commercial use"
- Clique em "Continue"

## ⚙️ Configuração Inicial

### Verificar Redes Virtuais

1. No VMware Workstation, vá para:

   ```
   Edit → Virtual Network Editor
   ```

2. **Clique em "Change Settings"** (requer admin)

3. **Verifique as redes**:

   **VMnet0 (Bridged)**:
   - Tipo: Bridged
   - Conecta VMs diretamente à rede física

   **VMnet1 (Host-only)**:
   - Tipo: Host-only
   - Subnet: 192.168.137.0
   - Máscara: 255.255.255.0
   - Comunicação apenas entre host e VMs

   **VMnet8 (NAT)**:
   - Tipo: NAT
   - Subnet: 192.168.88.0
   - Máscara: 255.255.255.0
   - DHCP habilitado

4. **Não altere nada por enquanto** - configuração padrão é adequada

### Configurar Preferências

1. Vá para:

   ```
   Edit → Preferences
   ```

2. **Aba "Workspace"**:
   - Default location for virtual machines:
     ```
     C:\VMs\
     ```
   - Crie esta pasta se não existir

3. **Aba "Memory"**:
   - Reserve memory for all VMs: **Automático** (recomendado)

4. **Aba "USB"**:
   - Deixe opções padrão

5. Clique em **"OK"**

## 🧪 Teste de Funcionamento

### Criar uma VM de Teste Simples

1. **Novo Wizard**:

   ```
   File → New Virtual Machine
   ```

2. **Configuração**:
   - Selecione "Typical"
   - Clique em "Next"

3. **Guest Operating System**:
   - Selecione "I will install the operating system later"
   - Clique em "Next"

4. **Sistema Operacional**:
   - Selecione "Linux"
   - Version: "Ubuntu 64-bit"
   - Clique em "Next"

5. **Nome e Local**:
   - Name: "Teste-VM"
   - Location: `C:\VMs\Teste-VM`
   - Clique em "Next"

6. **Tamanho do Disco**:
   - 20 GB
   - Store as a single file
   - Clique em "Next"

7. **Pronto**:
   - Clique em "Finish"

8. **Verificação**:
   - A VM deve aparecer na biblioteca
   - ✅ Se apareceu, VMware está funcionando corretamente
   - ❌ Se houver erro, veja seção de [Troubleshooting](#-troubleshooting)

9. **Remover VM de Teste**:
   - Clique com botão direito na VM
   - "Delete from Disk"

## 📦 Instalação no Linux (Resumo)

### Ubuntu/Debian

```bash
# Dar permissão de execução ao bundle
chmod +x VMware-Workstation-Full-17.x.x-xxxxx.x86_64.bundle

# Executar instalador
sudo ./VMware-Workstation-Full-17.x.x-xxxxx.x86_64.bundle

# Seguir o assistente de instalação
```

### Dependências (se necessário)

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)

# Fedora/RHEL
sudo dnf install kernel-devel kernel-headers gcc make
```

## 🔧 Troubleshooting

### Erro: "VMware Workstation and Hyper-V are not compatible"

**Solução**:

```cmd
# Abrir PowerShell como Administrador
bcdedit /set hypervisorlaunchtype off
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V

# Reiniciar o computador
shutdown /r /t 0
```

### Erro: "This host does not support Intel VT-x"

**Solução**:

1. Reinicie o computador
2. Entre na BIOS/UEFI
3. Habilite Intel VT-x ou AMD-V
4. Salve e reinicie

### Erro: Drivers de rede não instalam

**Solução**:

```cmd
# Reparar instalação de rede
"C:\Program Files (x86)\VMware\VMware Workstation\vmware-netcfg.exe"
```

### VMware não inicia

**Soluções**:

1. **Verificar serviços do Windows**:

   ```cmd
   services.msc
   ```

   Certifique-se que estes serviços estão rodando:
   - VMware Authorization Service
   - VMware DHCP Service
   - VMware NAT Service

2. **Reiniciar serviços**:
   ```cmd
   net stop "VMware Authorization Service"
   net start "VMware Authorization Service"
   ```

### Conflito com Antivírus

**Solução**:

- Adicione exceções no antivírus para:
  - `C:\Program Files (x86)\VMware\`
  - `C:\VMs\`
  - Processos: `vmware.exe`, `vmware-vmx.exe`

## ✅ Checklist de Verificação

- [ ] VMware Workstation instalado sem erros
- [ ] Licença ativada (trial ou completa)
- [ ] Redes virtuais (VMnet0, VMnet1, VMnet8) configuradas
- [ ] VM de teste criada e aparece na biblioteca
- [ ] Serviços VMware rodando
- [ ] Pasta padrão para VMs criada

## 📊 Informações Técnicas

### Arquivos e Pastas Importantes

| Item             | Localização                                         |
| ---------------- | --------------------------------------------------- |
| **Instalação**   | `C:\Program Files (x86)\VMware\VMware Workstation\` |
| **VMs Padrão**   | `C:\Users\<usuario>\Documents\Virtual Machines\`    |
| **Configuração** | `C:\ProgramData\VMware\`                            |
| **Logs**         | `C:\ProgramData\VMware\VMware Workstation\`         |

### Serviços do Windows

- VMware Authorization Service (VMAuthdService)
- VMware DHCP Service (VMnetDHCP)
- VMware NAT Service (VMware NAT Service)
- VMware USB Arbitration Service (VMUSBArbService)

## 🔄 Próximo Passo

VMware instalado e funcionando? Prossiga para:
➡️ [Instalação do EVE-NG](04-instalacao-eve-ng.md)

---

**Tempo Estimado**: 20-30 minutos  
**Dificuldade**: ⭐⭐☆☆☆ (Fácil)
