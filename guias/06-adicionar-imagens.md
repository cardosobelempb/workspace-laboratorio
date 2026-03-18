# 📦 Adicionar Imagens ao EVE-NG

## Visão Geral

Para usar dispositivos no EVE-NG, você precisa adicionar suas imagens (firmwares, ISOs, discos virtuais). Este guia mostra como adicionar MikroTik, Linux e outros dispositivos.

## 📋 Estrutura de Diretórios

O EVE-NG organiza imagens em diretórios específicos:

```
/opt/unetlab/addons/qemu/
├── linux-ubuntu-server-22/
├── linux-debian-11/
├── mikrotik-7.9/
└── outros-dispositivos/
```

Cada dispositivo tem sua própria pasta.

## 🔧 Métodos de Transferência de Arquivos

### Método 1: SCP (Recomendado)

**No Windows** (usando Bitvise SSH Client — SFTP):

1. Baixe **Bitvise SSH Client**: https://www.bitvise.com/ssh-client
2. Instale e abra o Bitvise SSH Client (inclui cliente SFTP gráfico)
3. Configure conexão SFTP:
   ```
   Host: 192.168.1.100
   Port: 22
   Username: root
   Password: [sua_senha_root] (ou use chave)
   ```
4. Conecte e, no painel SFTP, navegue até `/opt/unetlab/addons/qemu/`
5. Arraste e solte os arquivos para o diretório

**No Linux/Mac** (usando terminal):

```bash
# Upload de arquivo
scp imagem.img root@192.168.1.100:/tmp/

# Upload de pasta inteira
scp -r pasta/ root@192.168.1.100:/tmp/
```

### Método 2: Via Interface Web (Pequenos Arquivos)

⚠️ Limitado pelo tamanho do upload (verificar php.ini)

### Método 3: Montar Diretório Compartilhado

**Configure no VMware**:

1. VM Settings → Options → Shared Folders
2. Habilite e adicione pasta do Windows
3. No EVE-NG, monte a pasta

## 🛠️ Adicionar Imagem MikroTik CHR

### Passo 1: Preparar Imagem

1. **No seu computador**, localize:

   ```
   chr-7.xx.img
   ```

2. **Renomeie** para formato padronizado:
   ```
   virtioa.qcow2
   ```

### Passo 2: Criar Diretório

```bash
# Via SSH no EVE-NG
mkdir -p /opt/unetlab/addons/qemu/mikrotik-7.9

# Ajustar conforme sua versão (ex: 7.9, 7.10, etc)
```

### Passo 3: Transferir Arquivo

**Via SCP** (Windows — Bitvise SFTP ou Linux/Mac terminal):

```bash
# Converter IMG para QCOW2 (se necessário)
# No seu computador (se tem QEMU instalado):
qemu-img convert -f raw -O qcow2 chr-7.9.img virtioa.qcow2

# Upload (Linux/Mac via scp)
scp virtioa.qcow2 root@192.168.1.100:/opt/unetlab/addons/qemu/mikrotik-7.9/
```

**OU**, transfira o `.img` diretamente e converta no EVE-NG:

```bash
# Upload do arquivo IMG
scp chr-7.9.img root@192.168.1.100:/tmp/

# No EVE-NG, converter e mover
cd /opt/unetlab/addons/qemu/mikrotik-7.9/
/opt/qemu/bin/qemu-img convert -f raw -O qcow2 /tmp/chr-7.9.img virtioa.qcow2
```

### Passo 4: Ajustar Permissões

```bash
# No EVE-NG
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

### Passo 5: Verificar

```bash
# Listar imagens
ls -lh /opt/unetlab/addons/qemu/mikrotik-7.9/

# Deve mostrar:
# virtioa.qcow2
```

## 🐧 Adicionar Ubuntu Server

### Passo 1: Criar Diretório

```bash
mkdir -p /opt/unetlab/addons/qemu/linux-ubuntu-server-22
```

### Passo 2: Criar Disco Virtual

```bash
cd /opt/unetlab/addons/qemu/linux-ubuntu-server-22/

# Criar disco de 20GB
/opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 20G
```

### Passo 3: Transferir ISO

```bash
# No seu computador
scp ubuntu-22.04-live-server-amd64.iso root@192.168.1.100:/opt/unetlab/addons/qemu/linux-ubuntu-server-22/cdrom.iso
```

### Passo 4: Ajustar Permissões

```bash
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

### Passo 5: Instalação (após adicionar ao lab)

Quando adicionar ao lab:

1. O dispositivo bootará do ISO
2. Instale o Ubuntu normalmente
3. Após instalação, remova o cdrom.iso
4. Reinicie o dispositivo

## 🖥️ Adicionar Linux Client (Lubuntu)

### Método Similar ao Ubuntu Server

```bash
# Criar diretório
mkdir -p /opt/unetlab/addons/qemu/linux-lubuntu-22

# Criar disco
cd /opt/unetlab/addons/qemu/linux-lubuntu-22/
/opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 20G

# Transferir ISO
# (no seu computador)
scp lubuntu-22.04-desktop-amd64.iso root@192.168.1.100:/opt/unetlab/addons/qemu/linux-lubuntu-22/cdrom.iso

# Ajustar permissões
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

## 📝 Convenções de Nomenclatura

### Formato de Pasta

```
<tipo>-<nome>-<versao>
```

**Exemplos**:

- `mikrotik-7.9`
- `linux-ubuntu-server-22`
- `cisco-iosv-15.7`

### Nomes de Arquivos de Disco

| Nome            | Função                 |
| --------------- | ---------------------- |
| `virtioa.qcow2` | Disco principal (boot) |
| `virtiob.qcow2` | Disco adicional        |
| `virtioc.qcow2` | Disco adicional        |
| `cdrom.iso`     | CD-ROM de instalação   |

## 🔍 Verificar Imagens Disponíveis

### Via Interface Web

1. Crie um novo lab
2. Clique em "Add Node" (ícone de componente)
3. Selecione tipo de dispositivo
4. Se a imagem aparece na lista → ✅ Sucesso!

### Via SSH

```bash
# Listar todas as imagens
ls -lh /opt/unetlab/addons/qemu/

# Ver detalhes de uma imagem específica
ls -lh /opt/unetlab/addons/qemu/mikrotik-7.9/
```

## 🎨 Personalizar Templates (Avançado)

### Criar Template Personalizado

```bash
# Templates ficam em:
cd /opt/unetlab/html/templates/

# Copiar template existente como base
cp mikrotik.yml mikrotik-custom.yml

# Editar
nano mikrotik-custom.yml
```

**Exemplo de personalização**:

```yaml
---
type: qemu
name: MikroTik CHR Custom
description: MikroTik Cloud Hosted Router Personalizado
cpulimit: 1
icon: Router.png
cpu: 1
ram: 256
ethernet: 4
console: telnet
qemu_arch: x86_64
qemu_nic: virtio-net-pci
qemu_options: -machine type=pc,accel=kvm -cpu host
```

## 🔧 Troubleshooting

### Imagem não aparece na interface web

**Soluções**:

1. **Verificar nome da pasta**:

   ```bash
   # Formato correto
   /opt/unetlab/addons/qemu/[nome-dispositivo]/
   ```

2. **Verificar permissões**:

   ```bash
   /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
   ```

3. **Verificar arquivo de disco**:

   ```bash
   # Deve existir virtioa.qcow2 ou hda.qcow2
   ls -lh /opt/unetlab/addons/qemu/mikrotik-7.9/
   ```

4. **Limpar cache do navegador**:
   - Ctrl + Shift + R (recarregar forçado)

### Erro: "Cannot start node"

**Soluções**:

1. **Verificar formato do disco**:

   ```bash
   /opt/qemu/bin/qemu-img info virtioa.qcow2
   ```

2. **Recriar disco** (se corrupto):

   ```bash
   cd /opt/unetlab/addons/qemu/[dispositivo]/
   rm virtioa.qcow2
   /opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 20G
   ```

3. **Verificar RAM disponível**:
   ```bash
   free -h
   ```

### Dispositivo muito lento

**Soluções**:

- Aumente RAM da VM EVE-NG
- Reduza número de dispositivos simultâneos
- Use UKSM (memory deduplication)
- Verifique se virtualização aninhada está habilitada

## 📊 Tamanhos Recomendados de Disco

| Dispositivo         | Disco Mínimo | Recomendado |
| ------------------- | ------------ | ----------- |
| MikroTik CHR        | 128 MB       | 256 MB      |
| Linux Server Mínimo | 10 GB        | 20 GB       |
| Linux Desktop       | 15 GB        | 25 GB       |
| Cisco IOS           | 2 GB         | 4 GB        |

## 🚀 Otimizações

### Comprimir Imagens (Economizar Espaço)

```bash
# Converter para formato comprimido
/opt/qemu/bin/qemu-img convert -c -O qcow2 virtioa.qcow2 virtioa-compressed.qcow2

# Substituir original
mv virtioa-compressed.qcow2 virtioa.qcow2
```

### Clone de Imagens

```bash
# Clonar imagem existente
cp -r /opt/unetlab/addons/qemu/linux-ubuntu-server-22/ \
      /opt/unetlab/addons/qemu/linux-ubuntu-custom/

# Ajustar permissões
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

## ✅ Checklist

- [ ] Diretório criado com nome correto
- [ ] Arquivo de disco (virtioa.qcow2) presente
- [ ] Permissões ajustadas
- [ ] Imagem aparece na interface web
- [ ] Dispositivo consegue iniciar
- [ ] Performance adequada

## 📚 Referências

- **Documentação EVE-NG**: https://www.eve-ng.net/index.php/documentation/
- **Lista de imagens suportadas**: https://www.eve-ng.net/index.php/documentation/supported-images/
- **Cookbook (receitas)**: https://www.eve-ng.net/index.php/documentation/howtos/

## 🔄 Próximo Passo

Imagens adicionadas? Agora vamos configurá-las:
➡️ [Configuração do MikroTik](07-configuracao-mikrotik.md)

---

**Tempo Estimado**: 10-15 minutos por dispositivo  
**Dificuldade**: ⭐⭐⭐☆☆ (Média)
