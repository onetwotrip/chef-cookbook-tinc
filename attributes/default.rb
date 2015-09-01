default['tinc']['init_style'] = 'runit' # 'runit' or 'sysv'
default['tinc']['name'] = name.gsub(/[^a-z0-9]/, '_')
default['tinc']['address'] =
  ( node['cloud'] && node['cloud']['public_ipv4']) || node['ipaddress']
default['tinc']['networks'] = {
  'default' => {
    'port' => 655,
    'ipv4_subnet' => '172.23',
    'ipv6_subnet' => 'fc00:5ca1:ab1e',
    'hub_criteria' => "tags:tinc-hub",
    'peer_to_hub' => "chef_environment:#{node.environment}",
    'hub_to_hub' => "tags:tinc-hub",
  },
}
default['tinc']['networks_enable'] = {
  'default' => {
    'enable' => true,
    'extra_nets_routes' => {
      '10.10.10.10/24' => true,
    },
  }
}
