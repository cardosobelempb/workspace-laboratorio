# Lab ISP — Documentação de Referência

Laboratório de redes em Docker simulando um cenário de operadoras de
telecom com BGP, equipamentos MikroTik (RouterOS) reais, roteadores
Linux (FRR) e uma estação de cliente final com desktop gráfico.

Use este documento como consulta rápida para subir, acessar,
configurar e diagnosticar o ambiente.

---

## 1. Visão geral

| Componente | Papel no lab | Tecnologia |
|---|---|---|
| VIVO-CORE | Operadora — hub do BGP | RouterOS (QEMU) |
| CLARO-CORE | Operadora | RouterOS (QEMU) |
| MIKROTIK-001 | Roteador do cliente / CPE | RouterOS (QEMU) |
| GOIASTECH-CORE | Operadora parceira (só BGP) | Alpine + FRR |
| CONTABILIDADE-CORE | Rede adicional (só BGP) | Alpine + FRR |
| CLIENTE-PC | Estação do cliente final | Debian + desktop web (noVNC) |

Todos os nós estão conectados a um **backbone comum**
(`10.250.0.0/24`) e trocam rotas por **eBGP**, com cada nó usando um
número de sistema autônomo (AS) próprio.

---

## 2. Topologia

```
                     BACKBONE  10.250.0.0/24
                  (todos peeram via eBGP aqui)
   ┌──────────┬──────────┬───────────┬──────────────┬───────────┐
   │          │          │           │              │           │
VIVO       CLARO     GOIASTECH   CONTABILIDADE   MIKROTIK    CLIENTE-PC
.10        .20        .30          .40            .50          .60
AS65010   AS65020   AS65030      AS65040        AS65100      (host)
   │
   └── hub do BGP: as demais operadoras peeram com a VIVO
```

### Endereçamento

| Nó | IP backbone | Bloco anunciado (LAN) | AS |
|---|---|---|---|
| VIVO-CORE | 10.250.0.10 | 172.16.10.0/24 | 65010 |
| CLARO-CORE | 10.250.0.20 | 172.16.20.0/24 | 65020 |
| GOIASTECH-CORE | 10.250.0.30 | 10.10.0.0/24 | 65030 |
| CONTABILIDADE-CORE | 10.250.0.40 | 10.50.0.0/24 | 65040 |
| MIKROTIK-001 | 10.250.0.50 | 192.168.100.0/24 | 65100 |
| CLIENTE-PC | 10.250.0.60 | — | — |

---

## 3. Como subir e derrubar

Sempre execute os comandos na pasta do projeto (onde está o
`docker-compose.yml`).

### Subir tudo
```bash
docker compose up -d
docker compose ps
```

> RouterOS leva 30–60 s para bootar. Os nós Alpine baixam FRR/SSH no
> primeiro boot (requer internet uma vez). O CLIENTE-PC baixa a
> imagem do desktop no primeiro boot.

### Derrubar
```bash
docker compose down                 # para e remove containers + redes
docker compose down -v              # idem, e apaga os volumes (config dos RouterOS)
```

### Reiniciar um nó específico
```bash
docker compose restart vivo-core
```

### Recriar um nó do zero (mantendo os outros)
```bash
docker compose up -d --force-recreate vivo-core
```

### Limpeza completa (se houver redes/estado presos)
```bash
docker compose down --remove-orphans
docker network prune -f
docker compose up -d
```

---

## 4. Tabela de acesso

| Nó | Tipo | IP | SSH (host) | Winbox (host) | Usuário | Senha |
|---|---|---|---|---|---|---|
| VIVO-CORE | RouterOS | 10.250.0.10 | localhost:31022 | localhost:31091 | admin | admin |
| CLARO-CORE | RouterOS | 10.250.0.20 | localhost:32022 | localhost:32091 | admin | admin |
| GOIASTECH-CORE | Alpine+FRR | 10.250.0.30 | localhost:33022 | — | root | lab123 |
| CONTABILIDADE-CORE | Alpine+FRR | 10.250.0.40 | localhost:34022 | — | root | lab123 |
| MIKROTIK-001 | RouterOS | 10.250.0.50 | localhost:35022 | localhost:35091 | admin | admin |
| CLIENTE-PC | Desktop Linux | 10.250.0.60 | localhost:36022 | — | root | lab123 |

**Portas da API RouterOS (8728):** VIVO `31028`, CLARO `32028`,
MIKROTIK `35028`.

**Desktop do CLIENTE-PC:** navegador em `http://localhost:6080`
(senha `lab123`); VNC direto em `localhost:35900`.

---

## 5. Métodos de acesso

### 5.1 SSH (terminal)

Funciona em todos os nós. Use `127.0.0.1` em vez de `localhost` se
aparecer "Connection closed" (evita o IPv6 `::1`).

```bash
ssh -p 31022 admin@127.0.0.1     # VIVO
ssh -p 32022 admin@127.0.0.1     # CLARO
ssh -p 35022 admin@127.0.0.1     # MIKROTIK-001
ssh -p 33022 root@127.0.0.1      # GOIASTECH   (use 'vtysh' p/ o BGP)
ssh -p 34022 root@127.0.0.1      # CONTABILIDADE
ssh -p 36022 root@127.0.0.1      # CLIENTE-PC
```

**Termius:** crie um Host por nó — Address `localhost`, Port conforme
a tabela, Username/Password conforme a tabela. Ficam salvos para
reconectar com um clique.

### 5.2 Winbox (apenas RouterOS)

Campo **Connect To** no formato `host:porta`:

| Nó | Connect To | Login | Senha |
|---|---|---|---|
| VIVO-CORE | localhost:31091 | admin | admin |
| CLARO-CORE | localhost:32091 | admin | admin |
| MIKROTIK-001 | localhost:35091 | admin | admin |

Conecte sempre por **IP:porta** (a aba "Neighbors"/descoberta por MAC
não atravessa o NAT do Docker).

### 5.3 Acesso direto pelo Docker

Entra no container sem depender de porta/SSH. No Git Bash use o
prefixo `MSYS_NO_PATHCONV=1` para evitar a conversão de caminho:

```bash
MSYS_NO_PATHCONV=1 docker exec -it goiastech-core vtysh
MSYS_NO_PATHCONV=1 docker exec -it cliente-pc bash
```

> Nos RouterOS, `docker exec` cai no Linux que hospeda o QEMU, **não**
> no console do RouterOS — para o RouterOS em si, use SSH ou Winbox.

### 5.4 Desktop gráfico do CLIENTE-PC

- **Navegador:** `http://localhost:6080` (senha `lab123`)
- **VNC viewer:** `localhost:35900` (senha `lab123`)

Abra o terminal dentro do desktop e teste o alcance do lab, por ex.:
```
ping 10.250.0.10
```

---

## 6. Configuração

### 6.1 RouterOS (VIVO, CLARO, MIKROTIK-001)

Conecte por SSH ou Winbox e cole o conteúdo do `.rsc` correspondente
da pasta `configs/`. **Comece pela VIVO** — ela é o hub do BGP, todas
as outras operadoras peeram com ela.

Ordem sugerida:
1. `configs/vivo.rsc` → VIVO-CORE
2. `configs/claro.rsc` → CLARO-CORE
3. `configs/mikrotik-001.rsc` → MIKROTIK-001

Após o primeiro acesso, **troque a senha**:
```
/user set admin password=NOVA_SENHA
```

### 6.2 Nós FRR (GOIASTECH, CONTABILIDADE)

Sobem **já configurados** com BGP apontando para a VIVO — não é
preciso colar nada. Para ajustar manualmente, entre por SSH e use
`vtysh`.

---

## 7. Verificação e diagnóstico de BGP

### RouterOS
```
/routing bgp session print
/ip route print where bgp
/ip address print
```

### FRR (GOIASTECH / CONTABILIDADE)
```bash
docker exec -it goiastech-core vtysh -c "show bgp ipv4 summary"
docker exec -it goiastech-core vtysh -c "show ip route bgp"
```

Uma sessão saudável aparece como `Established` (RouterOS) ou com
contagem de prefixos > 0 no `summary` (FRR). Enquanto a VIVO não
estiver configurada, as sessões ficam em `Active`/`Connect`
(tentando) — isso é esperado.

---

## 8. Testes de conectividade

```bash
# do CLIENTE-PC (terminal do desktop ou via SSH) até a VIVO
ping 10.250.0.10

# de um RouterOS para outro (no terminal RouterOS)
/ping 10.250.0.20 count=4

# verificar quais rotas o nó aprendeu por BGP
/ip route print where bgp          # RouterOS
docker exec -it goiastech-core vtysh -c "show ip route bgp"   # FRR
```

---

## 9. Resolução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `Connection closed by ::1` no SSH | SSH tentando IPv6 | Use `127.0.0.1` no lugar de `localhost` |
| Winbox: "remote host closed the connection" | Nó travado no boot, ou versão de Winbox incompatível | `docker compose restart <no>`; use Winbox da mesma geração do RouterOS (v4 p/ ROS7, v3 p/ ROS6) |
| `docker exec ... no such file C:/...` | Git Bash convertendo o caminho | Prefixe com `MSYS_NO_PATHCONV=1` ou use `//bin/sh` |
| "Address already in use" ao subir | Redes/containers órfãos de execução anterior | `docker compose down --remove-orphans && docker network prune -f` |
| Só um nó falha (os outros OK) | Aquele container subiu mal | `docker compose restart <no>` ou `--force-recreate <no>` |
| Container em `Created`/reiniciando | Erro no boot daquele serviço | `docker logs <no> --tail 50` para ver a causa |
| Desktop web não abre em :6080 | CLIENTE-PC ainda baixando/instalando | Aguarde ~30 s; confira `docker logs cliente-pc` |

### Ver logs de um nó
```bash
docker logs vivo-core --tail 50
docker logs cliente-pc --tail 50
```

### Conferir o que está rodando e as portas
```bash
docker compose ps
```

---

## 10. Versão do RouterOS

Para saber qual versão de RouterOS a imagem está rodando (define qual
Winbox usar e qual sintaxe de configuração vale):

```
/system resource print
```

- RouterOS **7.x** → Winbox **4.x**, sintaxe BGP `/routing bgp connection`
- RouterOS **6.x** → Winbox **3.x**, sintaxe BGP `/routing bgp instance` + `/routing bgp peer`

Os arquivos em `configs/` usam a **sintaxe v7**.

---

## 11. Estrutura de arquivos do projeto

```
lab-isp-mix/
├── docker-compose.yml          # definição de todos os containers e redes
├── README.md                   # guia rápido
├── DOCUMENTACAO.md             # este documento
├── configs/
│   ├── vivo.rsc                # config RouterOS da VIVO (hub BGP)
│   ├── claro.rsc               # config RouterOS da CLARO
│   └── mikrotik-001.rsc        # config RouterOS do MIKROTIK-001
└── bitvise/
    ├── perfis-bitvise.txt      # dados dos perfis SSH p/ Bitvise/Termius
    └── conectar-todos.bat      # abre os 5 nós via CLI do Bitvise
```

---

## 12. Notas e limitações

- As senhas (`admin`, `lab123`) são apenas para uso local de
  laboratório. Troque-as antes de expor qualquer porta para fora da
  máquina.
- RouterOS CHR sem licença limita a banda a 1 Mbit/s após uso
  contínuo — irrelevante para estudar protocolos, mas não confunda
  com erro de configuração.
- Os RouterOS rodam em QEMU dentro do container; sem `/dev/kvm` o
  boot é mais lento (emulação pura), mas funciona.
- A imagem do RouterOS expõe de forma confiável uma rede de dados por
  container; por isso todos compartilham o backbone em vez de terem
  múltiplas interfaces físicas isoladas.
- O CLIENTE-PC, por padrão, alcança os nós pelo backbone. Para que a
  "navegação" dele saia simulando o caminho cliente→operadora seria
  necessário configurar rota/NAT adicional.


## Segundas instancias (adicionadas)

| No | Tipo | IP | AS | SSH | Winbox | Usuario | Senha | Bloco BGP |
|----|------|-----|-----|-----|--------|---------|-------|-----------|
| GOIASTECH-MIKROTIK     | RouterOS | 10.250.0.31 | 65031 | localhost:43022 | localhost:43091 | admin | admin | 10.11.0.0/24 |
| CONTABILIDADE-MIKROTIK | RouterOS | 10.250.0.41 | 65041 | localhost:44022 | localhost:44091 | admin | admin | 10.51.0.0/24 |
| MIKROTIK-002           | RouterOS | 10.250.0.51 | 65101 | localhost:45022 | localhost:45091 | admin | admin | 192.168.101.0/24 |

API RouterOS: GOIASTECH-MIKROTIK 43028, CONTABILIDADE-MIKROTIK 44028, MIKROTIK-002 45028.
Os tres sao RouterOS: configure colando um .rsc (use mikrotik-001.rsc como
base, trocando IP e AS para os valores acima).
