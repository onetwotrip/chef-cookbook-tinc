# Find unique IP address by taking 16 bits from node name's MD5,
# double-checking for conflicts by search.

def hex_address_unique?(hex_address)
  return false if hex_address == '0000'
  return false if hex_address == 'ffff'
  return search(:node, "tinc_hex_address:#{hex_address}").empty?
end

unless node['tinc']['hex_address']
  require 'digest/md5'
  ha_base = node.name
  loop do
    ha = Digest::MD5.hexdigest(ha_base)[-4..-1]
    Chef::Log.warn("HA: #{ha}")
    if hex_address_unique?(ha)
      node.set['tinc']['hex_address'] = ha
      node.save
      break
    end
    ha_base = "#{ha_base}'" # continuously adds one symbol
  end
end

node.set['tinc']['ipv4_address'] = [
  node['tinc']['ipv4_subnet'],
  node['tinc']['hex_address'][0..1].to_i(16),
  node['tinc']['hex_address'][2..3].to_i(16)
].join('.')

node.set['tinc']['ipv6_address'] = [
  node['tinc']['ipv6_subnet'],
  node['tinc']['hex_address'],
  '0:0:0:1'].join(':')
