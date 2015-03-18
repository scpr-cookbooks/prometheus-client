use_inline_resources

action :install do
  service new_resource.service do
    action    :nothing
    provider  Chef::Provider::Service::Upstart
    supports  [:start,:stop,:restart,:enable,:disable]
  end

  remote_file "#{node.prometheus_client.install_dir}/prometheus-node-exporter" do
    source    "#{node.prometheus_client.binary_path}/prometheus-node_exporter.#{node.prometheus_client.os}.#{node.prometheus_client.cpu_arch}"
    checksum  node.prometheus_client.node_exporter["#{node.prometheus_client.os}.#{node.prometheus_client.cpu_arch}"]
    mode      0755
    notifies  :restart, "service[#{new_resource.service}]"
  end

  template "/etc/init/#{new_resource.service}.conf" do
    action    :create
    source    "node_exporter.upstart.erb"
    cookbook  "prometheus-client"
    variables({
      resource:   new_resource
    })
    notifies :enable, "service[#{new_resource.service}]"
    notifies :start,  "service[#{new_resource.service}]"
  end

end

#----------

action :delete do

end