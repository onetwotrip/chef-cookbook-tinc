node['tinc']['networks'].each do |network_name, network|

  content_tinc_conf = <<EOF
Name = #{node['tinc']['name']}
GraphDumpFile = /var/run/tinc-#{network_name}.dot
Interface = tinc-#{network_name}
Cipher = aes128
EOF

  search(:node, "tinc_networks_#{network_name}_host_file:[* TO *]").each do |peer_node|
    next if peer_node.name == node.name # skip self
    file "/etc/tinc/#{network_name}/hosts/#{peer_node.name.gsub(/[^a-z0-9]/, '_')}" do
      content peer_node['tinc']['networks'][network_name]['host_file']
      mode 0600
    end
  end

  connect_to = []
  search_string = network['hub_criteria'] ? network['hub_to_hub'] : network['peer_to_hub']
  Chef::Log.warn("Tinc hub search string: \'#{search_string}\'")
  search(:node, "tinc_networks_#{network_name}_host_file:[* TO *] AND #{search_string}").each do |peer_node|

    next if peer_node.name == node.name # skip self
    connect_to << peer_node['tinc']['name']
  end
  content_connect_to = connect_to
                       .sort
                       .map { |peer| "ConnectTo = #{peer}\n" }
                       .join

  file "/etc/tinc/#{network_name}/tinc.conf" do
    content content_tinc_conf + content_connect_to
    notifies :reload, 'service[tinc]'
  end
end
