# padrão de nomenclatura de interfaces de rede (wan / lan / wi-fi)

Padrão pensado para ser usado em qualquer estabelecimento (loja, restaurante,
clínica, escritório, escola etc.), facilitando documentação, suporte remoto
e identificação rápida em topologia (Unifi, Mikrotik, pfSense, Omada, etc.).

Todos os nomes seguem **kebab-case minúsculo**, sem espaço, acento ou
underscore — formato seguro para uso direto em scripts (bash, regex, API de
controladores Wi-Fi, configuração via CLI).

---

## 1. estrutura geral do nome

```
[sigla-site]-[tipo]-[funcao-provedor]-[numero]
```

| campo | descrição | exemplo |
|---|---|---|
| sigla-site | código curto do estabelecimento/filial | rj01, sp-matriz, loja03 |
| tipo | wan, lan, wifi, vlan, mgmt | wan, lan, wifi |
| funcao-provedor | o que a interface serve ou qual provedor | vivo, caixa, clientes |
| numero | sequencial, quando houver mais de uma | 01, 02 |

---

## 2. nomenclatura por tipo de interface

### wan (link de internet)
```
wan-[provedor]-[num]
```
- `wan-vivo-01` → link primário
- `wan-claro-02` → link backup/failover
- `wan-starlink-01` → link via satélite (contingência)

### lan (rede cabeada / vlans internas)
```
lan-[funcao]-v[vlan]
```
- `lan-adm-v10` → administração/gerência
- `lan-pdv-v20` → caixas/pdv
- `lan-cftv-v50` → câmeras
- `lan-iot-v60` → automação, sensores, totens

### wi-fi (ssid)
```
[nome-estabelecimento]-[publico]
```
- `pizzaria-dosol-clientes`
- `pizzaria-dosol-staff`
- `pizzaria-dosol-gerencia` (oculto, se necessário)

### hotspot-marketing (portal cativo / wi-fi promocional)

**O que a pesquisa de mercado mostra (WiFire, DT Network, FlexSpot, Mambo Wi-Fi
e outras plataformas de "hotspot social" usadas no Brasil):** nenhuma delas
usa um prefixo técnico como `hotspot-marketing` no nome do SSID. Na prática
do dia a dia:

- o **SSID continua simples**, geralmente só o nome do estabelecimento
  (ex.: `pizzaria-dosol-wifi` ou `pizzaria-dosol`);
- toda a "mágica" do marketing (login social, captura de dados, tempo de
  sessão, pesquisa, voucher) acontece **dentro do portal cativo** — a
  página que abre no navegador antes de liberar a internet — e não no
  nome da rede;
- o cliente conecta no Wi-Fi, é redirecionado automaticamente para essa
  página, faz um cadastro rápido ou login social (Facebook, Google,
  Instagram, número de telefone), e só então recebe acesso à internet.

Ou seja: **o "marketing" mora no portal/splash page, não no SSID.**
Isso evita nomes longos e confusos para o cliente, que só vê e escolhe
o Wi-Fi pela lista do celular.

```
[nome-estabelecimento]-[complemento opcional]
```
- `pizzaria-dosol-wifi` → ssid único, simples, igual para todo público
- `pizzaria-dosol` → ainda mais direto, sem sufixo

Internamente (rede/vlan), ainda vale isolar essa rede do restante,
mesmo que o nome externo seja simples:
- `lan-hotspot-v35` → vlan dedicada ao tráfego do portal cativo
- `wan-hotspot-01` → uplink dedicado, se o provedor de hotspot exigir link próprio

Etapas do fluxo (ficam na configuração do portal, não no nome do ssid):
1. cliente conecta no ssid simples;
2. é redirecionado para a splash page (login social, cadastro ou voucher);
3. acesso liberado por tempo determinado, configurado no painel da plataforma.

> Dica: use **somente hífen, sem espaço, sem acento e sem underscore**
> em todos os nomes (wan, lan, vlan e ssid). Um único separador padronizado
> evita erro em script (bash, regex, grep, API de controladores Wi-Fi).

---

## 3. plano de vlans e faixas de ip padrão

Faixa sugerida usando `192.168.x.0/24`, onde **x = número da vlan**.
Assim o número da vlan e o terceiro octeto do ip **sempre coincidem** —
facilita memorizar e dar suporte.

| vlan | função | rede | gateway | exemplo de host |
|---|---|---|---|---|
| 10 | administração/gerência | 192.168.10.0/24 | 192.168.10.1 | 192.168.10.10 |
| 20 | caixa / pdv | 192.168.20.0/24 | 192.168.20.1 | 192.168.20.20 |
| 30 | wi-fi clientes | 192.168.30.0/24 | 192.168.30.1 | dhcp 192.168.30.100–250 |
| 35 | hotspot (portal cativo / wi-fi promocional) | 192.168.35.0/24 | 192.168.35.1 | dhcp 192.168.35.50–250 |
| 40 | wi-fi funcionários | 192.168.40.0/24 | 192.168.40.1 | dhcp 192.168.40.100–200 |
| 50 | cftv / câmeras | 192.168.50.0/24 | 192.168.50.1 | 192.168.50.10–60 |
| 60 | iot / automação | 192.168.60.0/24 | 192.168.60.1 | 192.168.60.10–100 |
| 99 | gerenciamento (switches, aps, roteador) | 192.168.99.0/24 | 192.168.99.1 | 192.168.99.2 (ap), .3 (switch) |

Para múltiplas filiais, acrescente o **número do site no segundo octeto**:
```
192.168.[site].[vlan]...
```
ou, se preferir cidr maior, use `10.[site].[vlan].0/24` (ex.: `10.3.20.0/24`
= filial 3, vlan de pdv).

---

## 4. exemplos aplicados por tipo de estabelecimento

### restaurante / lanchonete
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | dhcp/ip público do provedor |
| lan gerência | lan-adm-v10 | 192.168.10.0/24 |
| lan pdv | lan-pdv-v20 | 192.168.20.0/24 |
| wi-fi clientes | restaurante-sabor-clientes | 192.168.30.0/24 |
| hotspot (portal cativo, marketing fica na splash page) | restaurante-sabor-wifi | 192.168.35.0/24 |
| wi-fi staff | restaurante-sabor-staff | 192.168.40.0/24 |
| cftv | lan-cftv-v50 | 192.168.50.0/24 |

### hotel / pousada
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-claro-01 | ip público |
| wan backup | wan-vivo-02 | ip público (failover) |
| lan recepção | lan-recepcao-v10 | 192.168.10.0/24 |
| wi-fi hóspedes | hotel-vistamar-hospedes | 192.168.30.0/24 (isolada por vlan, sem acesso à lan interna) |
| hotspot (portal cativo, login social/voucher na splash page) | hotel-vistamar-wifi | 192.168.35.0/24 |
| wi-fi staff | hotel-vistamar-staff | 192.168.40.0/24 |
| iot (fechaduras, automação de quartos) | lan-iot-v60 | 192.168.60.0/24 |

### loja de varejo
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-oi-01 | ip público |
| lan pdv | lan-pdv-v20 | 192.168.20.0/24 |
| lan estoque | lan-estoque-v15 | 192.168.15.0/24 |
| wi-fi clientes | loja-centro-clientes | 192.168.30.0/24 |
| hotspot (portal cativo) | loja-centro-wifi | 192.168.35.0/24 |
| wi-fi gerência | loja-centro-gerencia (oculto) | 192.168.10.0/24 |

### clínica / consultório
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | ip público |
| lan administrativo | lan-adm-v10 | 192.168.10.0/24 |
| lan sistema/prontuário | lan-prontuario-v25 | 192.168.25.0/24 (rede crítica, isolada) |
| wi-fi pacientes | clinica-saude-pacientes | 192.168.30.0/24 |
| wi-fi equipe | clinica-saude-equipe | 192.168.40.0/24 |

### escritório corporativo
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-fibra-01 | ip público |
| wan backup (4g/5g) | wan-4g-02 | ip do operador móvel |
| lan colaboradores | lan-corp-v10 | 192.168.10.0/24 |
| lan servidores | lan-srv-v05 | 192.168.5.0/24 |
| wi-fi funcionários | empresa-xpto-corp | 192.168.10.0/24 (ou vlan própria 192.168.41.0/24) |
| wi-fi visitantes | empresa-xpto-visitantes | 192.168.31.0/24 (isolada da rede interna) |

### escola / faculdade
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | ip público |
| lan administrativo | lan-secretaria-v10 | 192.168.10.0/24 |
| lan laboratório | lan-lab-v12 | 192.168.12.0/24 |
| wi-fi alunos | escola-futuro-alunos | 192.168.30.0/24 |
| wi-fi professores | escola-futuro-professores | 192.168.40.0/24 |

### supermercado
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-claro-01 | ip público |
| lan pdv | lan-pdv-v20 | 192.168.20.0/24 |
| lan balanças/etiquetas | lan-iot-v60 | 192.168.60.0/24 |
| wi-fi clientes | mercado-bompreco-clientes | 192.168.30.0/24 |
| hotspot (portal cativo) | mercado-bompreco-wifi | 192.168.35.0/24 |
| cftv | lan-cftv-v50 | 192.168.50.0/24 |

### academia
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | ip público |
| lan recepção | lan-recepcao-v10 | 192.168.10.0/24 |
| wi-fi alunos | academia-forca-alunos | 192.168.30.0/24 |
| wi-fi staff | academia-forca-staff | 192.168.40.0/24 |

### condomínio
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | ip público |
| lan portaria | lan-portaria-v10 | 192.168.10.0/24 |
| lan cftv | lan-cftv-v50 | 192.168.50.0/24 |
| wi-fi área comum | condominio-jardim-comum | 192.168.30.0/24 |
| lan automação portão/interfone | lan-iot-v60 | 192.168.60.0/24 |

### posto de combustível
| interface | nome | ip/faixa |
|---|---|---|
| wan | wan-vivo-01 | ip público |
| lan pdv/bombas | lan-pdv-v20 | 192.168.20.0/24 |
| lan automação (bombas, tanques) | lan-iot-v60 | 192.168.60.0/24 |
| wi-fi clientes (loja de conveniência) | posto-rodovia-clientes | 192.168.30.0/24 |
| hotspot (portal cativo) | posto-rodovia-wifi | 192.168.35.0/24 |
| cftv | lan-cftv-v50 | 192.168.50.0/24 |

---

## 5. boas práticas

- **separe sempre** a rede de clientes (wi-fi público) da rede administrativa/pdv via vlan — segurança básica em pci-dss e lgpd.
- **padronize o gateway** sempre como `.1` da faixa, e o **ap/switch de gerenciamento** como `.2`/`.3` — facilita memorização.
- **documente em planilha** (site, vlan, ssid, senha, faixa de ip, gateway) e mantenha atualizada a cada nova filial.
- **use dhcp reservado** para impressoras, câmeras e equipamentos críticos (fora da faixa dinâmica).
- em multi-filial, inclua o **código do site** no nome do ssid e da vlan para evitar conflito ao gerenciar várias unidades no mesmo controlador (ex.: unifi/omada).
- **hotspot/portal cativo exige cuidado extra com lgpd**: mantenha o ssid simples e isole a rede em vlan própria, sem acesso à lan interna; documente, dentro da plataforma de hotspot, a finalidade da coleta de dados (e-mail, telefone, login social) e o tempo de retenção; mantenha a página de termos de uso visível na splash page antes da liberação do acesso.

---

## 6. exemplos de ssid — wi-fi público em serviços urbanos (surb)

> ⚠️ **nota de honestidade:** pesquisei em fornecedores reais de hotspot
> social no Brasil (wifire, dt network, flexspot, mambo wi-fi) e nenhum
> usa um prefixo técnico fixo tipo `surb-` como convenção de mercado —
> isso é uma **proposta de padronização própria**, não um padrão oficial
> que você vá encontrar documentado em algum órgão. A lógica por trás
> (nome fixo e reconhecível em toda a rede da cidade) é uma boa prática
> de segurança contra redes falsas, mas o prefixo em si é uma sugestão,
> não uma convenção já estabelecida — adapte a sigla para o que fizer
> sentido na sua cidade/órgão (ex.: a sigla real do seu serviço urbano).

Pensado para wi-fi público de **serviços urbanos/municipais** (terminais,
praças, postos de atendimento, transporte, saúde pública). Um prefixo
fixo e reconhecível ajuda o usuário a identificar a rede como legítima
— importante para evitar confusão com redes falsas ("evil twin") em
espaços públicos.

```
surb-[servico]-[publico-ou-funcao]
```

| ssid | contexto de uso | por que transmite segurança/simpatia |
|---|---|---|
| `surb-wifi-livre` | praça, parque, calçadão | nome simples e direto, "livre" reforça gratuidade sem parecer suspeito |
| `surb-conecta-cidade` | ponto genérico de cidade conectada | "conecta" tem tom convidativo, "cidade" reforça caráter público/oficial |
| `surb-terminal-seguro` | terminal de ônibus/rodoviária | "seguro" tranquiliza quem está em local de grande fluxo |
| `surb-saude-publica` | upa, posto de saúde, hospital municipal | identifica o órgão, gera confiança por ligação direta ao serviço público |
| `surb-biblioteca-livre` | biblioteca pública/municipal | tom educativo e acolhedor, sem soar comercial |
| `surb-prefeitura-oficial` | paços municipais, postos de atendimento | "oficial" reduz risco de o usuário cair em rede falsa homônima |
| `surb-praca-conecta` | praça pública específica | nome curto, fácil de identificar visualmente na lista de redes |
| `surb-transporte-livre` | metrô, vlt, estação de integração | junta contexto (transporte) + benefício (livre/gratuito) |
| `surb-cidadao-conecta` | postos de atendimento ao cidadão (poupatempo-like) | "cidadão" reforça que o serviço é para a população, gera pertencimento |
| `surb-parque-seguro` | parques e áreas de lazer | "seguro" tranquiliza famílias com crianças no ambiente |

Seguindo o que de fato acontece nas plataformas reais de hotspot (seção
2 acima): **o ssid fica fixo e simples**; login social, cadastro, tempo
de sessão e pesquisa de satisfação ficam na splash page, configurada no
painel da plataforma — não em sufixos no nome da rede.

> Dica de segurança para wi-fi urbano/público: evite siglas obscuras ou
> nomes genéricos demais (ex.: `wifi`, `free-internet`) — são os mais
> clonados por redes falsas. Usar um prefixo fixo e reconhecível em
> **todas** as unidades da cidade cria um padrão visual que o cidadão
> aprende a confiar, e que serve de base para campanhas de
> conscientização ("desconfie de wi-fi que não comece com surb-").

### sobre a variação "grátis por 2 minutos"

Como mostra a seção 2, **na prática o tempo grátis não vai no nome do
ssid** — ele é configurado dentro do portal cativo/plataforma de
hotspot, e aparece na splash page como texto ("você tem 2 minutos
grátis, cadastre-se para continuar"). Manter o ssid simples
(`surb-wifi-livre`, por exemplo) e colocar a regra de tempo só na tela
de login é o que reflete o uso real do mercado — evita ter que mudar
placa física ou nome de rede sempre que a regra de tempo mudar.

---

*adapte os números de vlan e as faixas de ip conforme o tamanho da rede — para redes pequenas (poucos dispositivos), `/24` é mais que suficiente; para redes maiores, considere `/23` ou subdividir mais vlans.*