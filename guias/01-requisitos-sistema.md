# 📋 Requisitos de Sistema

## Requisitos Mínimos e Recomendados

Para garantir o funcionamento adequado do laboratório, verifique se seu sistema atende aos seguintes requisitos:

### 💻 Hardware

#### Requisitos Mínimos

| Componente        | Especificação                          |
| ----------------- | -------------------------------------- |
| **Processador**   | Intel Core i5 ou AMD Ryzen 5 (4 cores) |
| **Virtualização** | Intel VT-x ou AMD-V habilitado na BIOS |
| **RAM**           | 8 GB                                   |
| **Armazenamento** | 100 GB livres em SSD                   |
| **Rede**          | Placa de rede Ethernet/Wi-Fi           |

#### Requisitos Recomendados

| Componente        | Especificação                                |
| ----------------- | -------------------------------------------- |
| **Processador**   | Intel Core i7/i9 ou AMD Ryzen 7/9 (8+ cores) |
| **Virtualização** | Intel VT-x/VT-d ou AMD-V habilitado          |
| **RAM**           | 16 GB ou mais                                |
| **Armazenamento** | 250 GB+ livres em NVMe SSD                   |
| **Rede**          | Placa de rede Gigabit Ethernet               |

### 🖥️ Sistema Operacional

#### Suportados

- ✅ Windows 10/11 Professional ou Enterprise (64-bit)
- ✅ Windows 10/11 Home (64-bit) - com limitações
- ✅ Linux Ubuntu 20.04/22.04 LTS
- ✅ Linux Debian 11/12

#### Não Recomendados

- ❌ Windows 7 ou anterior
- ❌ Sistemas 32-bit
- ❌ macOS (compatibilidade limitada)

## 🔧 Verificando Virtualização

### No Windows

1. **Via Task Manager (Gerenciador de Tarefas)**:

   ```
   1. Pressione Ctrl + Shift + Esc
   2. Vá para a aba "Performance" (Desempenho)
   3. Clique em "CPU"
   4. Verifique se "Virtualization" está "Enabled" (Habilitado)
   ```

2. **Via Command Prompt**:

   ```cmd
   systeminfo | findstr /i "virtualization"
   ```

3. **Se a virtualização estiver DESABILITADA**:
   - Reinicie o computador
   - Entre na BIOS/UEFI (geralmente F2, F10, Del ou Esc)
   - Procure por: "Intel VT-x", "AMD-V", "Virtualization Technology", "SVM Mode"
   - Habilite a opção
   - Salve e reinicie

### No Linux

```bash
# Verificar suporte a virtualização
egrep -c '(vmx|svm)' /proc/cpuinfo

# Se retornar número maior que 0, virtualização está disponível

# Verificar se módulos KVM estão carregados
lsmod | grep kvm
```

## 📦 Softwares Necessários

### VMware Workstation

| Item        | Especificação                              |
| ----------- | ------------------------------------------ |
| **Versão**  | VMware Workstation Pro 17.x ou Player 17.x |
| **Licença** | Pro (recomendado) ou Player (uso pessoal)  |
| **Espaço**  | ~600 MB                                    |

### EVE-NG

| Item            | Especificação                       |
| --------------- | ----------------------------------- |
| **Versão**      | EVE-NG Community Edition (ou Pro)   |
| **Formato**     | OVA (Open Virtualization Appliance) |
| **Espaço**      | ~4 GB (imagem base)                 |
| **RAM Alocada** | Mínimo 4 GB, recomendado 8 GB       |

### Imagens de Dispositivos

| Dispositivo                  | Tamanho Aproximado |
| ---------------------------- | ------------------ |
| MikroTik CHR                 | ~50 MB             |
| Linux Server (Ubuntu/Debian) | ~2-4 GB            |
| Linux Client                 | ~2-4 GB            |

## 🌐 Requisitos de Rede

- **Conexão Internet**: Necessária para:
  - Downloads iniciais
  - Atualizações de pacotes
  - Acesso ao EVE-NG via navegador
- **Portas Utilizadas**:
  - HTTP: 80 (EVE-NG Web Interface)
  - SSH: 22 (Acesso via terminal ao EVE-NG)
  - Telnet: 23 (Console dos dispositivos)
  - RDP: 3389 (Caso use Windows VMs)

## ⚠️ Considerações Importantes

### Antivírus e Firewall

- Alguns antivírus podem interferir com a virtualização
- Configure exceções para:
  - VMware Workstation
  - Pasta de VMs
  - Portas de rede utilizadas

### Hyper-V (Windows)

- ⚠️ **IMPORTANTE**: O Hyper-V e VMware não podem estar habilitados simultaneamente
- Se usar VMware, desabilite o Hyper-V:
  ```cmd
  # Execute como Administrador
  bcdedit /set hypervisorlaunchtype off
  dism.exe /Online /Disable-Feature:Microsoft-Hyper-V
  ```
- Reinicie o computador após desabilitar

### WSL2 (Windows Subsystem for Linux)

- WSL2 usa o Hyper-V por trás
- Pode causar conflitos com VMware
- Considere usar WSL1 ou desabilitar durante o uso do laboratório

## ✅ Checklist de Verificação

Antes de prosseguir, confirme:

- [ ] Processador com 4+ cores
- [ ] Virtualização habilitada na BIOS
- [ ] 8 GB+ de RAM disponível
- [ ] 100 GB+ de espaço em disco
- [ ] Sistema operacional 64-bit
- [ ] Hyper-V desabilitado (Windows)
- [ ] Conexão com internet estável
- [ ] Permissões de administrador

## 📊 Estimativa de Recursos por Cenário

### Cenário Básico (1-2 dispositivos)

- RAM: 8 GB total
- CPUs: 4 cores
- Armazenamento: 50 GB

### Cenário Intermediário (3-5 dispositivos)

- RAM: 12 GB total
- CPUs: 6 cores
- Armazenamento: 100 GB

### Cenário Avançado (6+ dispositivos)

- RAM: 16 GB+ total
- CPUs: 8+ cores
- Armazenamento: 150 GB+

## 🔄 Próximo Passo

Todos os requisitos atendidos? Prossiga para:
➡️ [Download dos Softwares Necessários](02-downloads.md)

---

**Dica**: Se seu hardware está no limite dos requisitos mínimos, considere:

- Executar menos dispositivos simultaneamente
- Usar imagens mais leves
- Aumentar o swap/página do sistema operacional
