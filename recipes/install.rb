include_recipe 'sysctl'
package 'tinc'

sysctl_param 'net.ipv6.conf.all.forwarding' do
  value 1
end
directory '/var/run/tinc'

netsboot = ""
node['tinc']['networks'].each do |network_name, network|
  network_enable = node['tinc']['networks_enable'][network_name]['enable']
  netsboot << "#{network_name}\n" if network_enable
  network_config_dir_path = "/etc/tinc/#{network_name}/hosts"

  directory network_config_dir_path do
    recursive true
  end

  case node['tinc']['init_style']
  when 'sysv'
    service 'tinc' do
      action [:start]
    end
  when 'runit'
    service 'tinc' do
      action [:disable, :stop]
    end

    opts = Hash.new
    opts['network_name'] = network_name
    runit_service "tinc" do
      service_name "tinc-#{network_name}"
      options opts
      restart_on_update true
      default_logger true
      action(network_enable ? :enable : :disable)
    end
    service "tinc-#{network_name}" do
      action :nothing
      supports :restart => true, :reload => true
    end
  else
    raise RuntimeError.new(("#{self.recipe_name} doesn't support init style '#{node['tinc']['init_style']}'"))
  end
end

file '/etc/tinc/nets.boot' do
  owner 'root'
  group 'root'
  mode '0644'
  content netsboot
end
