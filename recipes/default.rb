include_recipe 'tinc::install'
include_recipe 'tinc::config_ip'
include_recipe 'tinc::config_self' # Order is important, first self then peers
include_recipe 'tinc::config_peers'

service 'tinc' do
  action [:enable, :start]
end
