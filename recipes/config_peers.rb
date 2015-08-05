content_tinc_conf = <<EOF
Name = #{node['tinc']['name']}
GraphDumpFile = /var/run/tinc.dot
Interface = #{node['tinc']['interface']}
Cipher = aes128
EOF

connect_to = []

search(:node, 'tinc_host_file:[* TO *]').each do |peer_node|
  next if peer_node.name == node.name
  file "/etc/tinc/#{node['tinc']['net']}/hosts/#{peer_node['tinc']['name']}" do
    content peer_node['tinc']['host_file']
    mode 0600
  end
  connect_to << peer_node['tinc']['name']
end
content_connect_to = connect_to
                     .sort
                     .map { |peer| "ConnectTo = #{peer}\n" }
                     .join

file "/etc/tinc/#{node['tinc']['net']}/tinc.conf" do
  content content_tinc_conf + content_connect_to
  notifies :reload, 'service[tinc]'
end
