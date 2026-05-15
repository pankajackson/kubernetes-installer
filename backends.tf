terraform {
  backend "s3" {
    endpoints = {
      s3 = "http://s3.lxa.com"
    }

    bucket = "infra-tfstates"
    key    = "proxmox-k8s/terraform.tfstate"
    region = "us-east-1"

    use_path_style = true

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    # skip_region_validation      = true
    skip_requesting_account_id = true
  }
}