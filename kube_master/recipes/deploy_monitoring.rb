cookbook_file "/tmp/kube.tar.gz" do
  source 'kubernetes.tar.gz'
end

execute "Unpack files" do
  cwd "/tmp"
  command "tar xvf /tmp/kube.tar.gz"
end

execute "Deploy Monitoring" do
  cwd '/tmp/kubernetes/cluster-monitoring'
  command "kubectl create -f influxdb"
end
