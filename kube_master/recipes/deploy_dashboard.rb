cookbook_file "/tmp/kube.tar.gz" do
  source 'kubernetes.tar.gz'
end

execute "Unpack files" do
  cwd "/tmp"
  command "tar xvf /tmp/kube.tar.gz"
end

execute "Create Dashboard Controller" do
  cwd '/tmp/kubernetes/Dashboard'
  command "kubectl create -f dashboard-controller.yaml"
end

execute "Create Dashboard Service" do
  cwd '/tmp/kubernetes/Dashboard'
  command "kubectl create -f dashboard-service.yaml"
end