# dev-portfolio-iac

Infrastructure as Code (IaC) project for deploying a developer portfolio website on AWS using Terraform and Ansible.

## Overview

This project automates the provisioning and configuration of a portfolio website with:

- **Terraform**: Provisions AWS infrastructure (EC2, Route53)
- **Ansible**: Configures the server (Nginx, TLS certificates)
- **Let's Encrypt**: Automated SSL/TLS via Certbot

## Architecture

```
                    ┌─────────────────┐
                    │    Route53      │
                    │  DNS Zone       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   EC2 Instance  │
                    │  Ubuntu 24.04   │
                    │  ┌───────────┐  │
                    │  │   Nginx   │  │
                    │  │  + TLS    │  │
                    │  └───────────┘  │
                    └─────────────────┘
```

## Directory Structure

```
dev-portfolio-iac/
├── terraform/                  # Infrastructure provisioning
│   ├── main.tf                # AWS resources (EC2, Route53)
│   ├── providers.tf           # AWS provider config
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── terraform.tf           # Version constraints
├── ansible/                    # Configuration management
│   ├── ansible.cfg            # Ansible settings
│   ├── playbooks/
│   │   └── install_nginx.yml  # Server setup playbook
│   ├── inventory/
│   │   └── hosts.ini          # Target hosts
│   └── files/
│       ├── index.html         # Portfolio website
│       └── nginx.conf.j2      # Nginx config template
└── TODO.md                    # Roadmap
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.2
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- AWS CLI configured with appropriate credentials
- An existing AWS Key Pair for SSH access
- A registered domain with nameservers pointed to AWS Route53

## Setup

### 1. Provision Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply
```

### 2. Update Ansible Inventory

After Terraform completes, update `ansible/inventory/hosts.ini` with the EC2 public IP from the Terraform output.

### 3. Configure Server with Ansible

```bash
cd ansible

# Set SSH key path
export SSH_PRIVATE_KEY_FILE=/path/to/your/private-key.pem

# Run playbook
ansible-playbook -i inventory playbooks/install_nginx.yml
```

## Configuration

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-2` | AWS region |
| `instance_type` | `t2.micro` | EC2 instance type |
| `key_name` | `dev-portfolio-key` | AWS Key Pair name |

### Terraform Outputs

- `instance_id` - EC2 instance ID
- `instance_public_ip` - EC2 public IP address
- `instance_public_dns` - EC2 public DNS name
- `route53_name_servers` - Route53 nameservers for domain

## What Gets Deployed

1. **EC2 Instance**: Ubuntu 24.04 LTS (t2.micro)
2. **Route53 Zone**: DNS management for domain
3. **DNS Records**: A record for root domain, CNAME for www
4. **Nginx**: Web server with HTTPS enabled
5. **TLS Certificate**: Let's Encrypt certificate via Certbot

## Roadmap

See [TODO.md](TODO.md) for planned improvements including:

- Automated security group configuration
- AWS Key Pair automation
- Ansible roles refactoring
- Dynamic inventory

## License

MIT
