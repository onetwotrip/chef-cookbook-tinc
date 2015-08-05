include_recipe 'tinc::install'
include_recipe 'tinc::config_ip'
include_recipe 'tinc::config_peers'
include_recipe 'tinc::config_self'

service 'tinc' do
  action [:enable, :start]
end
