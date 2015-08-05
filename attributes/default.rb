default['tinc']['name'] = name.gsub(/[^a-z0-9]/, '_')
default['tinc']['address'] =
  ( node['cloud'] && node['cloud']['public_ipv4']) || node['ipaddress']

default['tinc']['networks'] = {
  'default' => {
    'enabled' => true,
    'name' => 'default',
    'interface' => 'tinc0',
    'ipv4_subnet' => '172.23',
    'ipv6_subnet' => 'fc00:5ca1:ab1e',
  },
}
