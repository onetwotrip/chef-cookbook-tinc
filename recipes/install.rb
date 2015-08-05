include_recipe 'sysctl'
package 'tinc'

sysctl_param 'net.ipv6.conf.all.forwarding' do
  value 1
end
directory '/var/run/tinc'

netsboot = ""
node['tinc']['networks'].each do |network_name, network|
  netsboot << "#{network_name}\n"
  network_config_dir_path = "/etc/tinc/#{network_name}/hosts"

  directory network_config_dir_path do
    recursive true
  end
end

file '/etc/tinc/nets.boot' do
  owner 'root'
  group 'root'
  mode '0644'
  content netsboot
end
