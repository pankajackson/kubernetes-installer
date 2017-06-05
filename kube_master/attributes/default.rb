case node['platform']
  when 'centos'
    default['update_repo'] = 'yum update all;'
    default['pack'] = ['kubernetes', 'etcd', 'flannel', 'iptables-services']
end

default['kube_config_dir'] = '/etc/kubernetes'
default['flanneld_config_file'] = '/etc/sysconfig/flanneld'
default['etcd_config_file'] = '/etc/etcd/etcd.conf'