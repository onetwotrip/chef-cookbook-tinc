include_recipe 'sysctl'
package 'tinc'

directory "/etc/tinc/#{node['tinc']['net']}/hosts" do
  recursive true
end

directory '/var/run/tinc'

file '/etc/tinc/nets.boot' do
  content "#{node['tinc']['net']}\n"
end

sysctl_param 'net.ipv6.conf.all.forwarding' do
  value 1
end
