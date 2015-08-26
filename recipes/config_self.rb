subnets_content = ''
node.attributes['network']['interfaces'].sort.each do |iface_name,iface|

  next if iface_name == 'lo'
  iface['addresses'].sort.each do |addr_name,addr|
    next if addr_name == node['tinc']['address'] # skip main IP
    next if not ['inet', 'inet6'].include?(addr['family'])
    subnets_content << "Subnet = #{addr_name}\n"
  end
end

node['tinc']['networks'].each do |network_name, network|
  network_enabled = node['tinc']['networks_enable'][network_name]
  next unless network_enabled

  execute "rm -f /etc/tinc/#{network_name}/tinc.conf" do
    creates "/etc/tinc/#{network_name}/rsa_key.pub"
  end
  execute "tincd -n #{network_name} -K 4096 < /dev/null" do
    creates "/etc/tinc/#{network_name}/rsa_key.pub"
  end

  ruby_block 'tinc::node_set_pub_key' do
    block do
      node.set['tinc']['networks'][network_name]['pub_key'] = File.read("/etc/tinc/#{network_name}/rsa_key.pub")
      node.save
    end
  end

  hostfile_content = <<EOF
Address = #{node['tinc']['address']}
Port = #{network['port']}
#{subnets_content}

#{node['tinc']['networks'][network_name]['pub_key']}
EOF

  file "/etc/tinc/#{network_name}/hosts/#{node['tinc']['name']}" do
    content hostfile_content
    action :create
  end

  ruby_block 'tinc::set_node_host_file' do
    block do
      node.set['tinc']['networks'][network_name]['host_file'] = hostfile_content
      node.save
    end
  end

  service_name = ''
  signal = :reload
  case node['tinc']['init_style']
  when 'sysv'
    service_name = 'tinc'
  when 'runit'
    service_name = "tinc-#{network_name}"
    signal = :hup
  end

  file "/etc/tinc/#{network_name}/tinc-up" do
    content <<EOF
#!/bin/sh
ifconfig $INTERFACE up \\
    #{network['ipv4_address']} netmask 255.255.0.0 \\
    add #{network['ipv6_address']}/64
ip -6 route add #{network['ipv6_subnet']}::/48 dev $INTERFACE
EOF
    mode 0755
    notifies signal, "service[#{service_name}]"
  end

  file "/etc/tinc/#{network_name}/tinc-down" do
    content <<EOF
#!/bin/sh
ifconfig $INTERFACE down
EOF
    mode 0755
    notifies signal, "service[#{service_name}]"
  end
end
