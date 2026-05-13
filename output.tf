output "kube_config" {
    sensitive = true
    value = module.k3s.secrets.kubeconfig
}
