# Lab ISP - misto RouterOS + Alpine/FRR

- VIVO, CLARO, MIKROTIK-001 -> RouterOS real
- GOIASTECH, CONTABILIDADE  -> Alpine + FRR + SSH (so BGP)

Backbone 10.250.0.0/24, eBGP entre si.

## Subir
    docker compose down --remove-orphans
    docker network prune -f
    docker compose up -d
    docker compose ps

RouterOS bootam em 30-60s. Os Alpine baixam FRR+openssh no 1o boot
(precisa internet uma vez) e sobem BGP+SSH sozinhos.

## Lista de acesso completa

| No | Tipo | IP backbone | IP LAN (lo) | AS | SSH (host) | Winbox (host) | Usuario | Senha |
|----|------|-------------|-------------|-----|-----------|----------------|---------|-------|
| VIVO          | RouterOS    | 10.250.0.10 | 172.16.10.1 | 65010 | localhost:31022 | localhost:31091 | admin | admin  |
| CLARO         | RouterOS    | 10.250.0.20 | 172.16.20.1 | 65020 | localhost:32022 | localhost:32091 | admin | admin  |
| GOIASTECH     | Alpine+FRR  | 10.250.0.30 | 10.10.0.1   | 65030 | localhost:33022 | -              | root  | lab123 |
| CONTABILIDADE | Alpine+FRR  | 10.250.0.40 | 10.50.0.1   | 65040 | localhost:34022 | -              | root  | lab123 |
| MIKROTIK-001  | RouterOS    | 10.250.0.50 | 192.168.100.1 | 65100 | localhost:35022 | localhost:35091 | admin | admin  |
| CLIENTE-PC    | Linux desktop | 10.250.0.60 | - | - | localhost:36022 | - | root | lab123 |

Porta API RouterOS (8728) tambem mapeada: VIVO 31028, CLARO 32028, MIKROTIK 35028.

### Cliente-PC (desktop Linux no navegador)
Tipo: Linux desktop (Debian + navegador) | IP backbone: 10.250.0.60

Acesso pelo NAVEGADOR (recomendado):
    http://localhost:6080      senha: lab123

Acesso por cliente VNC (Termius tem VNC, ou qualquer VNC viewer):
    Host: localhost   Porta: 35900   Senha: lab123

Acesso por SSH:
    ssh -p 36022 root@localhost      senha: lab123

Use para testar navegacao, ping e alcance a rede do lab de forma
visual, como se fosse o PC do cliente final. Abra o terminal do
desktop e teste, por ex.:  ping 10.250.0.10  (a VIVO).

### Exemplos de conexao SSH
    ssh -p 31022 admin@localhost     # VIVO
    ssh -p 32022 admin@localhost     # CLARO
    ssh -p 35022 admin@localhost     # MIKROTIK-001
    ssh -p 33022 root@localhost      # GOIASTECH  (vtysh pra mexer no BGP)
    ssh -p 34022 root@localhost      # CONTABILIDADE

### Acesso direto pelo Docker (sem SSH)
    docker exec -it vivo-core /bin/sh
    docker exec -it goiastech-core vtysh

## Configurar
- RouterOS (VIVO/CLARO/MIKROTIK): cole os .rsc de configs/. Comece pela VIVO.
- Alpine (GOIAS/CONTAB): ja sobem com BGP pronto. Pra mexer: logue via SSH
  e use "vtysh".

## Verificar BGP
RouterOS:  /routing bgp session print
Alpine:    vtysh -c "show bgp ipv4 summary"
           ou docker exec -it goiastech-core vtysh -c "show bgp ipv4 summary"

## Notas
- .rsc dos RouterOS usam sintaxe v7. Se a imagem for v6, avise.
- Senhas (admin / lab123) sao so pra lab local - troque se expor a rede.


## Segundas instancias (adicionadas)

| No | Tipo | IP | AS | SSH | Winbox | Usuario | Senha | Bloco BGP |
|----|------|-----|-----|-----|--------|---------|-------|-----------|
| GOIASTECH-MIKROTIK     | RouterOS | 10.250.0.31 | 65031 | localhost:43022 | localhost:43091 | admin | admin | 10.11.0.0/24 |
| CONTABILIDADE-MIKROTIK | RouterOS | 10.250.0.41 | 65041 | localhost:44022 | localhost:44091 | admin | admin | 10.51.0.0/24 |
| MIKROTIK-002           | RouterOS | 10.250.0.51 | 65101 | localhost:45022 | localhost:45091 | admin | admin | 192.168.101.0/24 |

API RouterOS: GOIASTECH-MIKROTIK 43028, CONTABILIDADE-MIKROTIK 44028, MIKROTIK-002 45028.
Os tres sao RouterOS: configure colando um .rsc (use mikrotik-001.rsc como
base, trocando IP e AS para os valores acima).
