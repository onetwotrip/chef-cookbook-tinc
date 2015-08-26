# Find unique IP address by taking 16 bits from node name's MD5,
# double-checking for conflicts by search.

def hex_address_unique?(net_name, hex_address)
  return false if hex_address == '0000'
  return false if hex_address == 'ffff'
  return search(:node, "tinc_#{net_name}_hex_address:#{hex_address}").empty?
end

node['tinc']['networks'].each do |network_name, network|
  unless node['tinc']['networks'][network_name]['hex_address']
    require 'digest/md5'
    hex_address_base = node.name
    loop do
      ha = Digest::MD5.hexdigest(hex_address_base)[-4..-1]
      Chef::Log.warn("Tinc hex address: #{ha}")
      if hex_address_unique?(network_name, ha)
        node.set['tinc']['networks'][network_name]['hex_address'] = ha
        node.save
        break
      end
      hex_address_base = "#{hex_address_base}'" # continuously adds one symbol
    end
  end

  node_hex_address = node['tinc']['networks'][network_name]['hex_address']
  node.set['tinc']['networks'][network_name]['ipv4_address'] = [
    network['ipv4_subnet'],
    node_hex_address[0..1].to_i(16),
    node_hex_address[2..3].to_i(16)
  ].join('.')

  node.set['tinc']['networks'][network_name]['ipv6_address'] = [
    network['ipv6_subnet'],
    node_hex_address,
    '0:0:0:1'].join(':')
end
