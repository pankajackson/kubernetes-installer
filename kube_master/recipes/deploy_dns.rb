cookbook_file "/tmp/kube.tar.gz" do
  source 'kubernetes.tar.gz'
end

execute "Unpack files" do
  cwd "/tmp"
  command "tar xvf /tmp/kube.tar.gz"
end

execute "Create DNS Controller" do
  cwd '/tmp/kubernetes/DNS'
  command "kubectl create -f skydns-rc.yaml"
end

execute "Create DNS Service" do
  cwd '/tmp/kubernetes/DNS'
  command "kubectl create -f skydns-svc.yaml"
end