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
    memory     = 4096
    disk       = 30
    ip_address = "192.168.1.10"
  }

  workers = {
    count    = 3
    cpu      = 3
    memory   = 16384
    disk     = 30
    ip_start = 11
  }

  network = {
    gateway = "192.168.1.2"
    dns = {
      servers = ["192.168.1.2", "192.168.1.1", "8.8.8.8"]
    }
    nfs = {
      server = "192.168.1.4"
      path   = "/volume1/infra-storage/lxa_k8s"
    }
  }

  k3s = {
    version = "v1.35.4+k3s1"
    tls_san = [
      "kube.lxa.com",
      "kubernetes.lxa.com",
      "k3s.lxa.com",
      "kube.linuxastra.in",
      "kubernetes.linuxastra.in",
      "k3s.linuxastra.com",
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
      ipaddress_pool = "192.168.1.200-192.168.1.250"
    }
    ingress_nginx = {
      enabled         = true
      loadbalancer_ip = "192.168.1.202"
    }
    nfs_storage = {
      enabled       = true
      server        = "192.168.1.4"
      path          = "/volume1/infra-storage/lxa_k8s"
      storage_class = "nfs"
    }
    headlamp = {
      enabled  = true
      hostname = "hl.lxa.com"
    }
  }
}