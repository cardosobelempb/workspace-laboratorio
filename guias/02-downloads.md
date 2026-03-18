# 📥 Download dos Softwares Necessários

## Lista de Downloads

Esta seção lista todos os softwares e imagens necessários para montar o laboratório completo.

## 1️⃣ VMware Workstation

### VMware Workstation Pro (Recomendado)

**Versão**: 17.x ou superior

**Download Oficial**:

- 🌐 Site: https://www.vmware.com/products/workstation-pro.html
- 💾 Tamanho: ~600 MB
- 🔑 Licença: Comercial (trial de 30 dias disponível)

**Passos**:

1. Acesse o site oficial da VMware
2. Clique em "Download Now" ou "Try for Free"
3. Crie uma conta VMware (se necessário)
4. Baixe a versão para seu sistema operacional:
   - Windows: `VMware-workstation-full-17.x.x-xxxxx.exe`
   - Linux: `VMware-Workstation-Full-17.x.x-xxxxx.x86_64.bundle`

### VMware Workstation Player (Alternativa Gratuita)

**Versão**: 17.x ou superior

**Download Oficial**:

- 🌐 Site: https://www.vmware.com/products/workstation-player.html
- 💾 Tamanho: ~200 MB
- 🔑 Licença: Gratuita para uso não comercial

**Limitações do Player**:

- ⚠️ Não permite criar múltiplas VMs simultaneamente
- ⚠️ Recursos avançados limitados
- ⚠️ Não recomendado para ambientes complexos

## 2️⃣ EVE-NG (Emulated Virtual Environment)

### EVE-NG Community Edition (Gratuita)

**Versão**: Mais recente disponível

**Download Oficial**:

- 🌐 Site: https://www.eve-ng.net/index.php/download/
- 💾 Formato: OVA (Open Virtual Appliance)
- 💾 Tamanho: ~4 GB
- 🔑 Licença: Community Edition (gratuita)

**Arquivo**:

```
EVE-Community-latest.ova
```

**Passos**:

1. Acesse https://www.eve-ng.net
2. Vá para a seção "Downloads"
3. Selecione "EVE Community Edition"
4. Registre-se (gratuito) se necessário
5. Baixe o arquivo OVA

### EVE-NG Pro (Opcional)

**Características**:

- Mais dispositivos suportados
- Recursos adicionais
- Suporte oficial
- 💰 Licença paga

## 3️⃣ Imagens de Dispositivos

### MikroTik Cloud Hosted Router (CHR)

**Versão**: Stable (estável) mais recente

**Download Oficial**:

- 🌐 Site: https://mikrotik.com/download
- 💾 Tamanho: ~50 MB
- 🔑 Licença: Gratuita para laboratório (limitações de velocidade)

**Arquivo Recomendado**:

```
chr-x.xx.img
```

**Passos**:

1. Acesse https://mikrotik.com/download
2. Procure por "Cloud Hosted Router"
3. Selecione "Raw disk image"
4. Baixe a versão "Stable"

**Formatos Disponíveis**:

- `.img` - Recomendado para EVE-NG
- `.vdi` - VirtualBox
- `.vmdk` - VMware (alternativo)

### Linux Server - Ubuntu Server

**Versão**: Ubuntu Server 22.04 LTS ou 20.04 LTS

**Download Oficial**:

- 🌐 Site: https://ubuntu.com/download/server
- 💾 Tamanho: ~1.5 GB (ISO)
- 🔑 Licença: Gratuita (Open Source)

**Arquivo**:

```
ubuntu-22.04.x-live-server-amd64.iso
```

**Alternativas**:

- Debian 12: https://www.debian.org/distrib/
- CentOS Stream: https://www.centos.org/download/

### Linux Client - Ubuntu Desktop

**Versão**: Ubuntu Desktop 22.04 LTS ou 20.04 LTS (versão reduzida)

**Download Oficial**:

- 🌐 Site: https://ubuntu.com/download/desktop
- 💾 Tamanho: ~3-4 GB (ISO)
- 🔑 Licença: Gratuita (Open Source)

**Arquivo**:

```
ubuntu-22.04.x-desktop-amd64.iso
```

**Alternativa Mais Leve**:

- **Lubuntu** (Ubuntu + LXDE):
  - 🌐 https://lubuntu.me/
  - 💾 Tamanho: ~2 GB
  - Recomendado para laboratórios (menor consumo de recursos)

## 4️⃣ Ferramentas Complementares (Opcionais)

### Cliente Telnet/SSH

**Windows**:

- **Bitvise SSH Client**: https://www.bitvise.com/ssh-client
  - Cliente SSH para Windows com SFTP embutido, túnel (port forwarding) e terminal gráfico.
  - Recomendado para este laboratório (substitui PuTTY/WinSCP em fluxos Windows).
- **Windows Terminal**: Microsoft Store
  - Moderno, suporte SSH nativo (Windows 10+)

**Linux**:

- OpenSSH (geralmente já instalado)
  ```bash
  # Verificar instalação
  ssh -V
  telnet
  ```

### Navegador Web

Para acessar a interface do EVE-NG:

- Google Chrome (Recomendado)
- Mozilla Firefox
- Microsoft Edge

**Importante**: Instale a extensão do EVE-NG para seu navegador.

### Cliente HTML5 do EVE-NG

**EVE-NG Client Pack** (Windows/Linux):

- 🌐 Site: https://www.eve-ng.net/index.php/download/
- Facilita conexão com consoles dos dispositivos

## 📂 Organização dos Downloads

Sugerimos criar uma estrutura de pastas organizada:

```
C:\Lab-EVE-NG\
├── Instaladores\
│   ├── VMware-workstation-full-17.x.x.exe
│   └── EVE-NG-Community-latest.ova
├── Imagens\
│   ├── MikroTik\
│   │   └── chr-7.xx.img
│   ├── Linux\
│   │   ├── ubuntu-22.04-server-amd64.iso
│   │   └── lubuntu-22.04-desktop-amd64.iso
│   └── Outros\
└── Documentacao\
    └── (este guia)
```

## ✅ Checklist de Downloads

Antes de prosseguir, confirme que baixou:

- [ ] VMware Workstation Pro ou Player
- [ ] EVE-NG Community Edition (arquivo .ova)
- [ ] MikroTik CHR (arquivo .img)
- [ ] Ubuntu Server ISO (ou alternativa)
- [ ] Ubuntu/Lubuntu Desktop ISO (ou alternativa)
- [ ] Cliente SSH/Telnet (Bitvise SSH Client recomendado)
- [ ] EVE-NG Client Pack (opcional)

## 🔐 Verificação de Integridade (Recomendado)

Após o download, verifique a integridade dos arquivos:

### Windows (PowerShell)

```powershell
# Calcular hash SHA256
Get-FileHash "caminho\do\arquivo" -Algorithm SHA256
```

### Linux

```bash
# Calcular hash SHA256
sha256sum arquivo.iso
```

Compare os hashes com os valores oficiais nos sites de download.

## ⚠️ Avisos Importantes

1. **Fontes Oficiais**: Sempre baixe de fontes oficiais
2. **Versões**: Use versões estáveis, não beta ou development
3. **Compatibilidade**: Verifique compatibilidade entre versões
4. **Licenças**: Respeite os termos de licença de cada software
5. **Armazenamento**: Reserve espaço adicional para instalação

## 🔄 Próximo Passo

Todos os downloads completos? Prossiga para:
➡️ [Instalação do VMware Workstation](03-instalacao-vmware.md)

---

**Tempo Estimado de Download**: 1-2 horas (dependendo da conexão)
