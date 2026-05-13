output "cluster_name" {
  value = module.k3s.cluster.name
}

output "cluster_id" {
  value = module.k3s.cluster.id
}

output "master_ip" {
  value = module.k3s.cluster.master
}

output "worker_ips" {
  value = module.k3s.cluster.workers
}

output "ssh_master" {
  value = module.k3s.access.ssh_master
}

output "kubeconfig_path" {
  value = module.k3s.access.kubeconfig_file
}

output "kubeconfig" {
  value     = module.k3s.secrets.kubeconfig
  sensitive = true
}

output "k3s_token" {
  value     = module.k3s.secrets.k3s_token
  sensitive = true
}