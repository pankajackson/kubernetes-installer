# Vagrantfile and Ansible Playbooks to Automate Kubernetes Setup using Kubeadm

## Prerequisites

1. Working Vagrant setup
2. 8 Gig + RAM workstation as the Vms use 4 vCPUS and 4+ GB RAM

## For MAC/Linux Users

Latest version of Virtualbox for Mac/Linux can cause issues because you have to create/edit the /etc/vbox/networks.conf file and add:

```conf
0.0.0.0/0 ::/0
```

or run below commands

```shell
sudo mkdir -p /etc/vbox/
echo "* 0.0.0.0/0 ::/0" | sudo tee -a /etc/vbox/networks.conf
```

So that the host only networks can be in any range, not just 192.168.56.0/21 as described here:
[https://discuss.hashicorp.com/t/vagrant-2-2-18-osx-11-6-cannot-create-private-network/30984/23](https://discuss.hashicorp.com/t/vagrant-2-2-18-osx-11-6-cannot-create-private-network/30984/23)

## NetPlan Setup (Optional)

To make kubernetes network secure try to create virtual IP in your local machine subnet with netplan tool. Below is an example of how you could do it.

edit file `/etc/netplan/01-network-manager-all.yaml` and Add extra/Virtual IP address (eg: 10.0.0.1) in same adapter in all the machines.

```shell
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s31f6:
      dhcp4: no
      addresses: [192.168.1.8/24, 10.0.0.1/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [192.168.1.8, 8.8.8.8]
```

## Usage/Examples

To provision the cluster, execute the following commands.

```shell
sudo apt install nfs-common nfs-kernel-server
git clone https://pankajackson@bitbucket.org/pankajackson/kubernetes-installer.git
cd kubernetes-installer
vagrant up
```

To provision the cluster along with node configurations in extra arguments, execute the following commands.

```shell
MASTER_CPU=4 WORKER_CPU=6 WORKER_MEMORY=6000 WORKER_COUNT=2 vagrant up
```

To provision the cluster in multiple physical machine, execute the following commands.

```shell
# execute in main physical that will deploy Kube Master Node
MASTER_CPU=4 WORKER_CPU=6 WORKER_MEMORY=6000 WORKER_COUNT=2 vagrant up

# execute in other physical that will deploy Kube Worker Node
WORKER_ONLY=true WORKER_CPU=2 WORKER_MEMORY=16384 WORKER_COUNT=3 START_IP=20 vagrant up
```

NOTE:

- WORKER_ONLY=true flag will connect to already created master Node instead of creating new Master Node
- Make Sure to change value of START_IP in every physical machine to avoid duplicate IPs in two kube worker node

## Set Kubeconfig file variable

```shell
cd kubernetes-installer
cd configs
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cp config ~/.kube/
```

## To shutdown the cluster

```shell
vagrant halt
```

## To restart the cluster

```shell
vagrant up
```

## To destroy the cluster

```shell
vagrant destroy -f
```
