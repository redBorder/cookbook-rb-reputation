# Cookbook:: rbreputation
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

rbreputation_config 'config' do
  name node['hostname']
  action :add
end
