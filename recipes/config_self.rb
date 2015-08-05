node['tinc']['networks'].each do |network_name, network|

  file "/etc/tinc/#{network_name}/hosts/#{node['tinc']['name']}" do
    content <<EOF
Address = #{node['tinc']['address']}
Subnet = #{node['tinc']['networks'][network_name]['ipv4_address']}
Subnet = #{node['tinc']['networks'][network_name]['ipv6_address']}
EOF
    action :create_if_missing
  end

  execute "tincd -n #{network_name} -K 4096 < /dev/null" do
    creates "/etc/tinc/#{network_name}/rsa_key.priv"
  end

  ruby_block 'tinc::host' do
    block do
      node.set['tinc']['networks'][network_name]['host_file'] = File.read("/etc/tinc/#{network_name}/hosts/#{node['tinc']['name']}")
      node.save
    end
  end

  file "/etc/tinc/#{network_name}/tinc-up" do
    content <<EOF
#!/bin/sh
ifconfig $INTERFACE up \\
    #{node['tinc']['networks'][network_name]['ipv4_address']} netmask 255.255.0.0 \\
    add #{node['tinc']['networks'][network_name]['ipv6_address']}/64
ip -6 route add #{node['tinc']['networks'][network_name]['ipv6_subnet']}::/48 dev $INTERFACE
EOF
    mode 0755
    notifies :restart, 'service[tinc]'
  end

  file "/etc/tinc/#{network_name}/tinc-down" do
    content <<EOF
#!/bin/sh
ifconfig $INTERFACE down
EOF
    mode 0755
    notifies :restart, 'service[tinc]'
  end

end
