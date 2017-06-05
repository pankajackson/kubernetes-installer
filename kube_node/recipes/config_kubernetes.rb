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

template "#{node['kube_config_dir']}/kubelet" do
  source 'kubelet.erb'
end

template "#{node['flanneld_config_file']}" do
  source 'flanneld.erb'
end

service 'kube-proxy' do
  action [ :enable, :start ]
end

service 'kubelet' do
  action [ :enable, :start ]
end

service 'flanneld' do
  action [ :enable, :start ]
end

service 'docker' do
  action [ :enable, :start ]
end
