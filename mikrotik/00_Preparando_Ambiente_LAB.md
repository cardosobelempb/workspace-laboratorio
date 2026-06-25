# Preparando o Ambiente de LAB — Curso MikroTik RouterOS v7

**Redes Brasil**

> O curso usa **EVE-NG** como plataforma de laboratório. Você tem 3 caminhos possíveis para montar seu ambiente.

---

## Opção A — LAB em Nuvem (Redes Brasil)

- Rápido e simples, **não consome CPU/RAM/Disco** da sua máquina
- Acesso direto aos roteadores MikroTik
- Outros inúmeros recursos prontos

### Passos
1. Localize o LAB em seu ambiente ou importe-o
2. Ligue e teste o acesso direto aos roteadores
3. Faça `ping` do roteador ligado à nuvem para a internet
4. Baixe e importe as configurações iniciais das operadoras

---

## Opção B — LAB Local (VM no seu PC)

### Requisitos mínimos
- PC 64 bits
- Virtualização ativada na BIOS
- 8 GB RAM (16 GB preferível)
- 4 cores de CPU
- 30 GB de SSD livre

### Passos de instalação
1. Baixe e instale o **VMware**
2. Baixe a **VM da Redes Brasil**
3. Faça a **importação** da VM
4. Verifique se a VM **pegou IP**
5. Verifique se **`kvm-ok`** está funcionando
6. Acesse o LAB e confirme que os **roteadores ligam normalmente**
7. Instale o **EVE Client Side**
8. Verifique se o roteador **pega IP pela nuvem**
9. Acesse o roteador (ex.: da Vivo) via **Winbox**

### ⚠️ Problemas comuns na VM do EVE-NG (Windows)

**1. Erro de virtualização mesmo com BIOS ativada**
> Mesmo com PC 64 bits e virtualização ativa na BIOS, o erro abaixo pode aparecer e os roteadores não ligam:
> `Virtualized Intel VT-x/EPT is not supported on this platform`

**2. Windows 11 — Integridade da Memória**
- Pode ser necessário **desabilitar a Integridade da Memória** em:
  `Segurança do Windows > Segurança do dispositivo > Isolamento de núcleo`

**3. Desabilitar o Hyper-V**
- Abra o **PowerShell como Administrador** e execute:
  ```powershell
  Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
  ```

**4. Desabilitar "Plataforma de Máquina Virtual"**
- Vá em `Painel de Controle > Programas > Recursos do Windows`
- Desmarque a opção **"Plataforma de Máquina Virtual"**

**5. Notebooks Dell — Mitigação de Segurança**
- Se aparecer problema de Mitigação, desabilite na **BIOS** a opção:
  **"SMM Security Mitigation"**

---

## Opção C — Já tenho EVE-NG rodando

### Passos
1. Baixe e importe as **imagens de roteadores e PCs**
2. Baixe e importe o **template do laboratório**
3. Baixe e importe as **configurações iniciais das operadoras**
4. Faça os testes para checar que está tudo funcionando

### Ferramentas de acesso
| Ferramenta | Uso |
|---|---|
| **EVE-Client** | Acesso via telnet e VNC |
| **Winbox** | Acessar os roteadores por interface gráfica |
| **RoMON** | Acesso alternativo via MikroTik (sem depender de IP direto) |
| **Moba Terminal** | Terminal recomendado para múltiplas sessões |

---

## Sobre o Laboratório (topologia geral)

```
Curso MikroTik RouterOS v7 - Redes Brasil
┌──────────────────────────────────────────────────────┐
│  GOIAS TECH        │   VIVO            │   CLARO      │
│  ┌──────────┐      │  ┌─────────┐      │  ┌────────┐  │
│  │GOIAS_TECH│──────┼──┤  VIVO   ├──────┼──┤ CLARO  │  │
│  └──────────┘ eth4 │  │(eth1=net)│ eth2│  └────────┘  │
│                     │  └────┬────┘      │              │
│                     │     eth3           │              │
└─────────────────────┼───────┼─────────────────────────┘
                       │     eth1
                  ┌────┴─────┐
                  │ CPE-VIVO │
                  └────┬─────┘
                      eth2/eth1
                  ┌────┴──────┐      ┌────────────────────┐
                  │MIKROTIK-001│      │ CONTABILIDADE BRASIL│
                  └────┬───────┘      └────────────────────┘
                      eth2/e0
                   ┌───┴───┐
                   │ VPC-1 │
                   └───────┘
```

**Componentes:**
- **GOIAS TECH** — operadora/empresa parceira (bloco de IP próprio)
- **VIVO** e **CLARO** — operadoras simuladas, cada uma com sua estrutura de rede
- **CPE-VIVO** — equipamento cliente (modem/roteador da operadora)
- **MIKROTIK-001** — roteador principal usado nos laboratórios práticos
- **VPC-1** — PC virtual do cliente final, usado para testes
- **CONTABILIDADE BRASIL** — rede adicional usada em exercícios específicos (ex.: VPN, BGP)

---

## Informações das Operadoras (referência para todo o curso)

### Vivo
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.64.1.0/24` ou `200.10.1.0/24` |
| DHCP | `100.64.2.0/24` ou `200.10.2.0/24` |
| IP fixo sem VLAN | `200.10.3.0/30` |
| IP fixo com VLAN (VLAN 200) | `200.10.3.4/30` |
| Bloco para rotear | `200.10.3.248/29` |
| Bloco Goias Tech | `200.10.3.8/30` |

### Claro
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.77.1.0/24` ou `77.10.1.0/24` |
| DHCP | `100.77.2.0/24` ou `77.10.2.0/24` |
| IP fixo sem VLAN | `77.10.3.0/30` |
| IP fixo com VLAN (VLAN 77) | `77.10.3.4/30` |
| Bloco para rotear | `77.10.3.248/29` |

---

## ✅ Checklist final antes de começar o Módulo 1

- [ ] Ambiente de LAB escolhido e funcionando (nuvem ou local)
- [ ] Consigo acessar os roteadores via Winbox/EVE-Client
- [ ] Roteador da operadora (Vivo/Claro) responde a `ping`
- [ ] Configurações iniciais das operadoras já importadas
- [ ] Sei localizar o `MIKROTIK-001` e o `VPC-1` na topologia

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
