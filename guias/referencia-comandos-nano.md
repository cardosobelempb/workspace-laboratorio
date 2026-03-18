# 📝 Referência de Comandos do Nano

## Visão Geral

O **nano** é o editor de texto padrão em muitos sistemas Linux e é amplamente usado nos guias deste laboratório. Esta referência lista os comandos mais importantes.

## 🚀 Iniciando o Nano

```bash
# Abrir arquivo existente
nano arquivo.txt

# Criar novo arquivo
nano novoarquivo.txt

# Abrir com número de linhas
nano +10 arquivo.txt

# Abrir arquivo como root (sudo)
sudo nano /etc/hosts
```

## ⌨️ Comandos Essenciais

### Navegação

| Comando        | Ação            | Descrição                 |
| -------------- | --------------- | ------------------------- |
| **Setas ↑↓←→** | Mover cursor    | Navegação básica          |
| **Ctrl + A**   | Início da linha | Move cursor para o início |
| **Ctrl + E**   | Fim da linha    | Move cursor para o final  |
| **Ctrl + Y**   | Página anterior | Sobe uma tela             |
| **Ctrl + V**   | Próxima página  | Desce uma tela            |
| **Ctrl + G**   | Ir para linha   | Digite número da linha    |
| **Alt + G**    | Ir para linha   | Alternativa para Ctrl+G   |

### Edição Básica

| Comando              | Ação                 | Descrição                            |
| -------------------- | -------------------- | ------------------------------------ |
| **Ctrl + K**         | Cortar linha         | Remove linha atual                   |
| **Ctrl + U**         | Colar/Desfazer corte | Cola linha cortada                   |
| **Ctrl + 6**         | Iniciar seleção      | Marcar texto (Space também funciona) |
| **Alt + 6**          | Copiar seleção       | Copia texto selecionado              |
| **Ctrl + K**         | Cortar seleção       | Corta texto selecionado              |
| **Delete/Backspace** | Apagar caractere     | Apaga caractere atual/anterior       |

### Busca e Substituição

| Comando       | Ação            | Descrição                 |
| ------------- | --------------- | ------------------------- |
| **Ctrl + W**  | Buscar          | Procurar texto no arquivo |
| **Ctrl + \\** | Substituir      | Buscar e substituir texto |
| **Alt + W**   | Buscar próximo  | Repetir última busca      |
| **Alt + Q**   | Buscar anterior | Busca anterior            |

### Salvar e Sair

| Comando      | Ação                 | Descrição                         |
| ------------ | -------------------- | --------------------------------- |
| **Ctrl + O** | Salvar               | Write Out (salvar arquivo)        |
| **Ctrl + X** | Sair                 | Sair do nano                      |
| **Ctrl + S** | Salvar (alternativo) | Funciona em versões mais recentes |

**Sequência comum**: `Ctrl + O` → `Enter` → `Ctrl + X`

### Utilitários

| Comando      | Ação                 | Descrição                   |
| ------------ | -------------------- | --------------------------- |
| **Ctrl + G** | Ajuda                | Mostra todos os comandos    |
| **Ctrl + T** | Verificar ortografia | Corretor ortográfico        |
| **Ctrl + J** | Justificar parágrafo | Reformatar texto            |
| **Ctrl + C** | Posição do cursor    | Mostra linha e coluna atual |

## 🎯 Casos de Uso Comuns no Laboratório

### 1. Editar Configuração de Rede (Netplan)

```bash
sudo nano /etc/netplan/00-installer-config.yaml

# Comandos úteis:
# Ctrl + W → procurar "addresses"
# Ctrl + A/E → ir para início/fim da linha
# Ctrl + O → salvar
# Ctrl + X → sair
```

### 2. Editar Arquivo de Hosts

```bash
sudo nano /etc/hosts

# Adicionar entrada:
# Ctrl + E → ir para fim da linha
# Enter → nova linha
# Digite: 192.168.10.10   servidor.lab.local
# Ctrl + O → salvar
# Ctrl + X → sair
```

### 3. Editar Configuração SSH

```bash
sudo nano /etc/ssh/sshd_config

# Procurar configuração:
# Ctrl + W → digite "Port"
# Alterar valor
# Ctrl + O → salvar
# Ctrl + X → sair
```

### 4. Criar Script de Backup

```bash
nano /home/user/backup.sh

# Escrever script completo
# Ctrl + O → salvar
# Ctrl + X → sair
# chmod +x backup.sh → tornar executável
```

## 🔧 Configurações Úteis

### Arquivo de Configuração (~/.nanorc)

Crie um arquivo de configuração personalizada:

```bash
nano ~/.nanorc
```

**Configurações recomendadas**:

```bash
# Mostrar números de linha
set linenumbers

# Quebra automática de linha
set softwrap

# Destacar sintaxe
include /usr/share/nano/*.nanorc

# Auto-indentação
set autoindent

# Mostrar espaços em branco
set whitespace

# Backup automático
set backup

# Mouse support (se disponível)
set mouse

# Mostrar posição do cursor
set constantshow
```

## ⚡ Dicas e Truques

### Seleção de Texto

1. **Posicione o cursor** no início do texto
2. **Ctrl + 6** (ou Alt + A) para iniciar seleção
3. **Mova o cursor** para selecionar texto
4. **Ctrl + K** para cortar ou **Alt + 6** para copiar

### Busca Eficiente

```bash
# Buscar palavra
Ctrl + W → digite palavra → Enter

# Buscar próxima ocorrência
Alt + W

# Buscar com regex (versões mais novas)
Ctrl + W → Alt + R → digite regex
```

### Trabalhar com Múltiplas Linhas

```bash
# Cortar várias linhas
Ctrl + 6 → selecione linhas → Ctrl + K

# Duplicar linha
Ctrl + 6 → selecione linha → Alt + 6 → Ctrl + U
```

## 🚨 Comandos de Emergência

### Arquivo Muito Grande

```bash
# Visualizar apenas (sem carregar na memória)
less arquivo.txt
# ou
more arquivo.txt

# Editar parte específica
head -n 100 arquivo.txt > temp.txt
nano temp.txt
```

### Sair Sem Salvar

```bash
# Se fez alterações por engano
Ctrl + X → N (No) → sair sem salvar
```

### Recuperar de Crash

```bash
# nano cria backups automáticos em caso de crash
# Procure arquivos .save
ls -la *.save

# Recuperar
nano arquivo.txt.save
```

## 📋 Referência Rápida

### Comandos Mais Usados (Top 10)

1. **Ctrl + X** - Sair
2. **Ctrl + O** - Salvar
3. **Ctrl + W** - Buscar
4. **Ctrl + K** - Cortar linha
5. **Ctrl + U** - Colar
6. **Ctrl + A** - Início da linha
7. **Ctrl + E** - Fim da linha
8. **Ctrl + G** - Ajuda
9. **Ctrl + C** - Ver posição
10. **Ctrl + \\** - Substituir

### Para Memorizar

**"COX"** - As três operações essenciais:

- **C**trl + **C** (posição)
- **C**trl + **O** (salvar)
- **C**trl + **X** (sair)

## 🎓 Exercícios Práticos

### Exercício 1: Configuração Básica

1. Crie arquivo: `nano teste.txt`
2. Digite algumas linhas de texto
3. Salve com `Ctrl + O`
4. Saia com `Ctrl + X`

### Exercício 2: Busca e Substituição

1. Abra arquivo: `nano teste.txt`
2. Busque palavra: `Ctrl + W`
3. Substitua texto: `Ctrl + \`
4. Salve e saia

### Exercício 3: Seleção e Cópia

1. Abra arquivo grande
2. Selecione parágrafo: `Ctrl + 6`
3. Copie: `Alt + 6`
4. Cole em outro local: `Ctrl + U`

## 🔄 Integração com Outros Comandos

### Pipes e Redirecionamento

```bash
# Editar resultado de comando
ps aux | grep apache > processos.txt
nano processos.txt

# Editar e aplicar configuração
nano config.txt && sudo cp config.txt /etc/
```

### Com Git

```bash
# Editar mensagem de commit
git commit
# nano abrirá automaticamente para mensagem

# Editar conflitos
git mergetool
# Configure nano como editor padrão:
git config --global core.editor "nano"
```

## 💡 Alternativas ao Nano

Para referência, outros editores populares:

| Editor    | Dificuldade              | Uso                            |
| --------- | ------------------------ | ------------------------------ |
| **nano**  | ⭐ Fácil                 | Edições simples, iniciantes    |
| **vim**   | ⭐⭐⭐⭐ Difícil         | Power users, edição avançada   |
| **emacs** | ⭐⭐⭐⭐⭐ Muito difícil | Programação, ambiente completo |
| **micro** | ⭐⭐ Fácil-médio         | Alternativa moderna ao nano    |

**Recomendação**: Use nano para este laboratório - é simples e eficiente!

---

**Dica**: Mantenha esta referência aberta enquanto segue os guias do laboratório. Com o tempo, os comandos se tornarão automáticos!
