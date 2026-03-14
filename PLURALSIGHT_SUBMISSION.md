# Pluralsight Security Hands-On Technical Audition Submission

## Question 1: Experience with Bash, PowerShell, or Terraform

I have practical experience with:

### TERRAFORM
- Created complete AWS infrastructure using HashiCorp Configuration Language (HCL)
- Implemented VPC, public subnets, security groups, and EC2 instances
- Managed IAM roles, SSH key pairs, and security configurations
- Used Terraform variables and outputs for infrastructure flexibility and reusability
- Automated entire lab environment provisioning from scratch
- Handled infrastructure state management and provider plugins

### BASH
- Written shell scripts for system reconnaissance and log analysis
- Implemented file investigation tools using grep, find, sed, and awk
- Worked with system administration and file permissions
- Created automated testing and validation scripts
- Implemented error handling and conditional logic in scripts

### PROJECT APPLICATION
This forensics lab demonstrates applying these skills to create a realistic security incident investigation environment. The lab uses Terraform to provision AWS infrastructure and Bash concepts to simulate attack evidence that students investigate.

---

## Question 2: Network Diagram or Description

### Forensics Lab Architecture

```
┌──────────────────────────────────────────────────────────┐
│              AWS Region: us-east-1                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────┐     │
│  │  VPC: 10.0.0.0/16                             │     │
│  │                                                │     │
│  │  ┌──────────────────────────────────────────┐ │     │
│  │  │  Public Subnet: 10.0.1.0/24              │ │     │
│  │  │                                          │ │     │
│  │  │  ┌────────────────────────────────────┐  │ │     │
│  │  │  │  EC2 Instance (t3.micro)           │  │ │     │
│  │  │  │  Ubuntu 22.04 LTS                  │  │ │     │
│  │  │  │  Public IP: Dynamic                │  │ │     │
│  │  │  │  Private IP: 10.0.1.x              │  │ │     │
│  │  │  │                                    │  │ │     │
│  │  │  │  Compromised Server:               │  │ │     │
│  │  │  │  ├─ SSH logs (attack evidence)    │  │ │     │
│  │  │  │  ├─ Bash history (commands)       │  │ │     │
│  │  │  │  ├─ Backdoor scripts              │  │ │     │
│  │  │  │  └─ Cron jobs (persistence)       │  │ │     │
│  │  │  └────────────────────────────────────┘  │ │     │
│  │  │                                          │ │     │
│  │  │  Security Group:                        │ │     │
│  │  │  - Inbound: SSH (22) from 0.0.0.0/0    │ │     │
│  │  │  - Outbound: All traffic allowed        │ │     │
│  │  └──────────────────────────────────────────┘ │     │
│  │                                                │     │
│  │  ┌──────────────────────────────────────────┐ │     │
│  │  │  Internet Gateway                        │ │     │
│  │  └──────────────────────────────────────────┘ │     │
│  │         ↕                                     │     │
│  │  ┌──────────────────────────────────────────┐ │     │
│  │  │  Route Table: 0.0.0.0/0 → IGW           │ │     │
│  │  └──────────────────────────────────────────┘ │     │
│  │                                                │     │
│  └────────────────────────────────────────────────┘     │
│                                                          │
└──────────────────────────────────────────────────────────┘
                          ↕
                   Your SSH Client
                  (Investigation Point)
```

### Infrastructure Components

**VPC Configuration:**
- CIDR Block: 10.0.0.0/16
- DNS Hostnames: Enabled
- DNS Support: Enabled

**Public Subnet:**
- CIDR Block: 10.0.1.0/24
- Availability Zone: Dynamically selected
- Auto-assign Public IP: Enabled

**Internet Gateway:**
- Attached to VPC
- Routes all outbound traffic (0.0.0.0/0)

**Security Group:**
- SSH (Port 22): Open to 0.0.0.0/0 (for lab access)
- All Outbound: Allowed
- Purpose: Allow remote investigation

**EC2 Instance:**
- Instance Type: t3.micro (eligible for AWS Free Tier)
- AMI: Ubuntu 22.04 LTS (latest)
- Storage: Default EBS volume
- Purpose: Simulates compromised server

### Evidence on Server

**Authentication Logs:**
- Location: `/var/log/auth.log`
- Content: SSH brute force attack logs
- Attacker IP: 203.45.67.89
- Success timestamp: ~1 hour ago

**Command History:**
- Location: `/home/ubuntu/.bash_history` and `/root/.bash_history`
- Content: Commands executed by attacker
- Actions: Download, installation, persistence setup

**Backdoor Files:**
- Location: `/tmp/.hidden/`
- Files: monitor.sh, system-check, update.py
- Purpose: Reverse shell and persistence mechanism

**Scheduled Tasks:**
- Location: `/var/spool/cron/crontabs/`
- Content: Malicious cron jobs
- Frequency: Every 15 minutes

---

## Question 3: GitHub Username and Repository

**GitHub Username:** rodrigo.americo

**Repository Link:** https://github.com/rodrigo.americo/forensics-lab

**Repository Status:** Public ✓

**Repository Settings:**
- Visibility: Public
- License: MIT (optional)
- .gitignore: Configured for Terraform
- Size: ~11 KB (optimized)

---

## Lab Usage Instructions

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with credentials
- SSH client
- Internet connection

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/rodrigo.americo/forensics-lab.git
cd forensics-lab/terraform

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Deploy the infrastructure
terraform apply

# 5. Connect to the server
export SERVER_IP=$(terraform output -raw server_ip)
ssh -i keys/globomantics.pem ubuntu@$SERVER_IP

# 6. Investigate the compromised server
# See README.md for detailed investigation steps

# 7. Cleanup when finished
terraform destroy
```

---

## Lab Learning Objectives

Upon completion of this forensics lab, students will be able to:

- **Analyze** authentication logs for attack patterns
- **Identify** indicators of compromise (IoCs)
- **Track** attacker activities through command history
- **Detect** backdoors and persistence mechanisms
- **Create** forensic timelines of security incidents
- **Document** findings professionally
- **Understand** real-world incident response procedures

---

## Technical Details

**Terraform Configuration:**
- Infrastructure as Code: Complete automation
- Provider: AWS (HashiCorp)
- Language: HCL (HashiCorp Configuration Language)
- Files: main.tf, variables.tf, user-data.sh

**User Data Script:**
- Size: 8,286 bytes (within AWS limits)
- Language: Bash
- Purpose: Simulates security incident on instance startup
- Security: No persistence on termination

**Server Simulation:**
- Attack Timeline: ~1 hour prior to investigation
- Evidence Realism: Based on actual attack patterns
- Educational Value: Real-world incident response scenarios

---

## Files Included in Repository

```
forensics-lab/
├── README.md                    # Lab overview and instructions
├── SOLUCAO.md                   # Expected solutions and timeline
├── PLURALSIGHT_SUBMISSION.md    # This file
├── .gitignore                   # Git ignore configuration
└── terraform/
    ├── main.tf                  # AWS infrastructure definition
    ├── variables.tf             # Terraform variables
    ├── user-data.sh             # Server initialization script
    └── keys/                    # SSH keys (generated on apply)
```

---

## Support and Resources

For more information about this lab:
- Check `README.md` for detailed investigation walkthrough
- Review `SOLUCAO.md` for expected findings
- Terraform documentation: https://www.terraform.io/docs
- AWS documentation: https://docs.aws.amazon.com

---

**Lab Status:** Ready for submission ✓
**Last Updated:** March 14, 2024
**Lab Type:** Forensics Investigation (Beginner Level)
**Difficulty:** Beginner-to-Intermediate
**Time to Complete:** 25-40 minutes
