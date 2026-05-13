# Terraform K3s Infrastructure

Infrastructure repository for provisioning a fully automated K3s Kubernetes cluster on Proxmox VE using the [terraform-proxmox-k8s module](https://github.com/pankajackson/terraform-proxmox-k8s).

This repository acts as the **consumer/root Terraform project** and contains:

- Provider configuration
- Environment-specific variables
- Cluster definitions
- Terraform state management
- Generated kubeconfig and access helpers

---

## Requirements

| Name       | Version |
| ---------- | ------- |
| Terraform  | >= 1.5  |
| Proxmox VE | >= 7.x  |

---

## Providers

| Name    | Source        |
| ------- | ------------- |
| proxmox | `bpg/proxmox` |

---

## Repository Structure

```text
.
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── test.auto.tfvars
├── .generated/
│   ├── kubeconfig.yaml
│   └── vm_key.pem
└── README.md
```

---

## Usage

### 1. Clone Repository

```bash
git clone https://github.com/pankajackson/kubernetes-installer.git
cd kubernetes-installer
```

---

### 2. Configure Variables

Create or edit:

```text
test.auto.tfvars
```

Example:

```hcl
proxmox_endpoint = "https://192.168.1.2:8006/"
proxmox_username = "root@pam"
proxmox_password = "your-password"

proxmox_tls_insecure = true
```

---

### 3. Initialize Terraform

```bash
terraform init
```

---

### 4. Review Plan

```bash
terraform plan
```

---

### 5. Apply Infrastructure

```bash
terraform apply
```

---

## Example Cluster Configuration

```hcl
module "k3s" {
  source = "git::https://github.com/pankajackson/terraform-proxmox-k8s.git"

  proxmox = {
    node = "proxmox"
  }

  cluster = {
    name = "k8s"
  }

  master = {
    cpu        = 2
    memory     = 2048
    disk       = 30
    ip_address = "192.168.1.10"
  }

  workers = {
    count    = 2
    cpu      = 3
    memory   = 4096
    disk     = 30
    ip_start = 11
  }

  network = {
    gateway = "192.168.1.1"

    dns = {
      servers = [
        "192.168.1.1",
        "8.8.8.8"
      ]
    }

    nfs = {
      server = "192.168.1.253"
      path   = "/data/lxa_k8s"
    }
  }

  k3s = {
    version = "v1.35.4+k3s1"

    tls_san = [
      "kube.example.com",
      "kubernetes.example.com",
      "k3s.example.com",
      "k8s.example.com"
    ]

    features = {
      metrics       = true
      local_storage = true
      traefik       = false
    }
  }

  addons = {
    metallb = {
      enabled        = true
      ipaddress_pool = "192.168.1.100-192.168.1.250"
    }

    ingress_nginx = {
      enabled         = true
      loadbalancer_ip = "192.168.1.202"
    }

    nfs_storage = {
      enabled       = true
      server        = "192.168.1.253"
      path          = "/data/lxa_k8s"
      storage_class = "nfs"
    }

    headlamp = {
      enabled  = true
      hostname = "hl.example.com"
    }
  }
}
```

---

## Provider Configuration

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.5"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_tls_insecure

  ssh {
    agent = true
  }
}
```

---

## Variables

### Proxmox Credentials

| Name                   | Type     | Sensitive | Description           |
| ---------------------- | -------- | --------- | --------------------- |
| `proxmox_endpoint`     | `string` | no        | Proxmox API endpoint  |
| `proxmox_username`     | `string` | no        | Proxmox API username  |
| `proxmox_password`     | `string` | yes       | Proxmox API password  |
| `proxmox_tls_insecure` | `bool`   | no        | Skip TLS verification |

---

## Outputs

Example outputs configuration:

```hcl
output "cluster" {
  value = module.k3s.cluster
}

output "access" {
  value = module.k3s.access
}

output "secrets" {
  value     = module.k3s.secrets
  sensitive = true
}
```

---

## Accessing Cluster

### Export KUBECONFIG

```bash
export KUBECONFIG=.generated/kubeconfig.yaml
```

---

### Verify Cluster

```bash
kubectl get nodes
```

---

### SSH Into Master Node

```bash
ssh -i .generated/vm_key.pem lxa@192.168.1.10
```

---

## Generated Files

Terraform module automatically generates:

```text
.generated/
├── kubeconfig.yaml
└── vm_key.pem
```

These files are generated in the **root Terraform repository**.

---

## Recommended Remote State

For production usage, use remote state storage:

- Terraform Cloud
- OpenTofu State
- S3 Compatible Storage
- GitLab Remote State

Example:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "k3s/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Common Commands

### Upgrade Module

```bash
terraform init -upgrade
```

---

### Recreate Addons Only

```bash
terraform apply -replace="module.k3s.null_resource.addons_bootstrap[0]"
```

---

### Destroy Cluster

```bash
terraform destroy
```

---

## Notes

- Worker cleanup executes automatically during destroy
- Cloud-init readiness is validated before K3s bootstrap
- Addons are deployed using Helmfile
- MetalLB should use dedicated IP ranges only
- Kubeconfig is downloaded automatically after cluster bootstrap
- Generated files are written to the root Terraform project

---

## Module

Terraform module used by this repository:

[terraform-proxmox-k8s](https://github.com/pankajackson/terraform-proxmox-k8s)
