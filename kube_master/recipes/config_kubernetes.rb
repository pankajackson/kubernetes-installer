execute "Backup Configs" do
  command "cp -rv #{node['kube_config_dir']} #{node['kube_config_dir']}_orig"
end

service 'firewalld' do
  action [ :disable, :stop ]
end

service 'iptables' do
  action [ :enable, :start ]
end

execute "Save Static Firewall Rules" do
  command "iptables -F; service iptables save"
end

template "#{node['kube_config_dir']}/config" do
  source 'config.erb'
end

cookbook_file "#{node['etcd_config_file']}" do
  source 'etcd.conf'
end

cookbook_file '/tmp/make-ca-cert.sh' do
  source 'make-ca-cert.sh'
  mode '0755'
end

execute "Create Certificates and Keys" do
  cwd "/tmp"
  command "bash make-ca-cert.sh \"#{node["ipaddress"]}\" \"IP:#{node["ipaddress"]},IP:10.254.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local\""
end

template "#{node['kube_config_dir']}/apiserver" do
  source 'apiserver.erb'
end

cookbook_file "#{node['kube_config_dir']}/controller-manager" do
  source 'controller-manager'
end

service 'etcd' do
  action [ :enable, :start ]
end

execute "ETCD Make Dir" do
  command "etcdctl mkdir /kube-centos/network"
end

execute "ETCD Network Config" do
  command 'etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"'
end

template "#{node['flanneld_config_file']}" do
  source 'flanneld.erb'
end

service 'etcd' do
  action [ :enable, :start ]
end

service 'kube-apiserver' do
  action [ :enable, :start ]
end

service 'kube-controller-manager' do
  action [ :enable, :start ]
end

service 'kube-scheduler' do
  action [ :enable, :start ]
end

service 'flanneld' do
  action [ :enable, :start ]
end
