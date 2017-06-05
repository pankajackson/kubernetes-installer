if node['platform'] == 'centos'
  yum_repository 'virt7-docker-common-release' do
    description "virt7-docker-common-release Stable repo"
    baseurl "http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/"
    gpgcheck false
    action :create
  end
end
