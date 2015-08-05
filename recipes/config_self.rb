file "/etc/tinc/#{node['tinc']['net']}/hosts/#{node['tinc']['name']}" do
  content <<EOF
Address = #{node['tinc']['address']}
Subnet = #{node['tinc']['ipv4_address']}
Subnet = #{node['tinc']['ipv6_address']}
EOF
  action :create_if_missing
end

execute "tincd -n #{node['tinc']['net']} -K 4096 < /dev/null" do
  creates "/etc/tinc/#{node['tinc']['net']}/rsa_key.priv"
end

ruby_block 'tinc::host' do
  block do
    node.set['tinc']['host_file'] = File.read("/etc/tinc/#{node['tinc']['net']}/hosts/#{node['tinc']['name']}")
    node.save
  end
end

file "/etc/tinc/#{node['tinc']['net']}/tinc-up" do
  content <<EOF
#!/bin/sh
ifconfig $INTERFACE up \\
    #{node['tinc']['ipv4_address']} netmask 255.255.0.0 \\
    add #{node['tinc']['ipv6_address']}/64
ip -6 route add #{node['tinc']['ipv6_subnet']}::/48 dev $INTERFACE
EOF
  mode 0755
  notifies :restart, 'service[tinc]'
end

file "/etc/tinc/#{node['tinc']['net']}/tinc-down" do
  content <<EOF
#!/bin/sh
ifconfig $INTERFACE down
EOF
  mode 0755
  notifies :restart, 'service[tinc]'
end
