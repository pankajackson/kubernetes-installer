# -*- mode: ruby -*-
# vi: set ft=ruby :

DEFAULT_NETWORK_INTERFACE = `ip route | awk '/^default/ {printf "%s", $5; exit 0}'`

ENV['VAGRANT_NO_PARALLEL'] = 'yes'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox' # virtualbox or libvirt

VAGRANT_BOX         = "bento/ubuntu-22.04"
VAGRANT_BOX_VERSION = "202309.08.0"
VAGRANT_BOX_CHECK_UPDATE = false

MASTER_CPU      = (ENV['MASTER_CPU']    || 2).to_i
MASTER_MEMORY   = (ENV['MASTER_MEMORY'] || 4096).to_i

WORKER_CPU      = (ENV['WORKER_CPU']    || 7).to_i
WORKER_MEMORY   = (ENV['WORKER_MEMORY'] || 55000).to_i
WORKER_COUNT    = (ENV['WORKER_COUNT']  || 3).to_i
WORKER_ONLY     = ENV['WORKER_ONLY'] == "true"

STORAGE_CPU     = 1
STORAGE_MEMORY  = 1024
STORAGE_IP      = 254

NETWORK         = "10.0.0.X"
START_IP        = (ENV['START_IP']      || 10).to_i

puts "Worker Only = #{WORKER_ONLY}"
puts "Default network Interface = #{DEFAULT_NETWORK_INTERFACE}"
puts "Start IP = #{START_IP}"

Vagrant.configure("2") do |config|

    # Global
    config.vm.box = VAGRANT_BOX
    config.vm.box_check_update = VAGRANT_BOX_CHECK_UPDATE
    config.vm.box_version      = VAGRANT_BOX_VERSION
    config.ssh.forward_agent   = true
    config.vm.synced_folder ".", "/vagrant", disabled: false,
        id: "vagrant", 
        automount: true
    config.vm.provider :libvirt do |libvirt|
        libvirt.nested = true
        libvirt.driver = "kvm"
    end

    if !(WORKER_ONLY)
        # Master
        config.vm.define "master" do |master|
            ip_address = NETWORK.gsub('X', "#{START_IP}")
            master.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address

            # Master VirtualBox
            master.vm.provider :virtualbox do |vbox|
                vbox.name   = "master"
                vbox.cpus   = MASTER_CPU
                vbox.memory = MASTER_MEMORY
            end

            # Master LibVirt
            master.vm.provider :libvirt do |libvirt|
                libvirt.cpus   = MASTER_CPU
                libvirt.memory = MASTER_MEMORY
            end
        end

        # Storage
        config.vm.define "storage" do |storage|
            ip_address = NETWORK.gsub('X', "#{STORAGE_IP}")
            storage.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address

            # Storage VirtualBox
            storage.vm.provider :virtualbox do |vbox|
                vbox.name   = "storage"
                vbox.cpus   = STORAGE_CPU
                vbox.memory = STORAGE_MEMORY
                vb_machine_folder = `vboxmanage list systemproperties | grep "Default machine folder" | cut -d ':' -f2`.strip
                disk_path = File.join(vb_machine_folder, "storage", "data_storage.vdi")
                
                # Check if the disk already exists, and if not, create it
                unless File.exist?(disk_path)
                    vbox.customize ['createhd', '--filename', disk_path, '--size', 256000] # Size in MB, e.g., 10GB
                end

                # Attach the disk to the VM
                vbox.customize [
                'storageattach', :id,
                '--storagectl', 'SATA Controller',
                '--port', 1,
                '--device', 0,
                '--type', 'hdd',
                '--medium', disk_path
                ]
            end

            # Storage LibVirt
            storage.vm.provider :libvirt do |libvirt|
                libvirt.cpus    = STORAGE_CPU
                libvirt.memory  = STORAGE_MEMORY
                libvirt.machine_virtual_size = 250
            end
        end
    end

    (1..WORKER_COUNT).each do |i|
        # Worker
        config.vm.define "worker#{format('%02d', i)}" do |node|
            ip_address = NETWORK.gsub('X', "#{START_IP + i}")
            node.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address

            # Worker VirtualBox
            node.vm.provider :virtualbox do |vbox|
                vbox.name   = "worker#{format('%02d', i)}"
                vbox.cpus   = WORKER_CPU
                vbox.memory = WORKER_MEMORY
            end
    
            # Worker LibVirt
            node.vm.provider :libvirt do |libvirt|
                libvirt.cpus   = WORKER_CPU
                libvirt.memory = WORKER_MEMORY
            end

            # Parallel Provision
            if i == WORKER_COUNT
                node.vm.provision "ansible" do |ansible|
                    ansible.limit = "all"
                    ansible.playbook = "playbooks/kube-installer.yml"
                    ansible.extra_vars = {
                        version: 1.31,
                        domain: "jackson.com",
                        worker_only: WORKER_ONLY,
                        storage_ip: NETWORK.gsub('X', "#{STORAGE_IP}"),
                        vagrant: {
                            config_path: "/vagrant/configs",
                            shared_config_path: "/data/configs",
                        }
                        
                    }
                end
            end
        end
    end
end
