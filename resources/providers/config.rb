# Cookbook:: rb-reputation
# Provider:: config

action :add do
  begin
    memory = new_resource.memory
    log_dir = new_resource.log_dir
    config_dir = new_resource.config_dir
    aerospike_ips = new_resource.aerospike_ips
    user = new_resource.user
    group = new_resource.group

    execute 'create_user' do
      command "/usr/sbin/useradd #{user} -s /sbin/nologin"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    dnf_package 'rb-reputation' do
      action :upgrade
    end

    directory config_dir do
      owner user
      group group
      mode '700'
      action :create
    end

    directory log_dir do
      owner user
      group group
      mode 0770
      action :create
    end

    template '/etc/rb-reputation/init_options.sh' do
      source 'rb-reputation_init_options.sh.erb'
      owner user
      group group
      mode '0644'
      retries 2
      cookbook 'rb-reputation'
      variables(memory: memory)
      notifies :restart, 'service[rb-reputation]', :delayed
    end

    template '/etc/rb-reputation/config.properties' do
      source 'rb-reputation_config.properties.erb'
      owner user
      group group
      mode '0644'
      retries 2
      cookbook 'rb-reputation'
      variables(memory: memory, aerospike_ips: aerospike_ips)
      notifies :restart, 'service[rb-reputation]', :delayed
    end

    template '/etc/rb-reputation/weights.yml' do
      source 'rb-reputation_weights.yml.erb'
      owner user
      group group
      mode '0644'
      retries 2
      cookbook 'rb-reputation'
      variables(memory: memory)
      notifies :restart, 'service[rb-reputation]', :delayed
    end

    service 'rb-reputation' do
      service_name 'rb-reputation'
      ignore_failure true
      supports status: true, reload: true, restart: true
      action [:enable, :start]
    end

    Chef::Log.info('cookbook rb-reputation has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'rb-reputation' do
      service_name 'rb-reputation'
      supports status: true, restart: true, start: true, enable: true, disable: true
      action [:disable, :stop]
    end
    Chef::Log.info('cookbook rb-reputation has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['rb-reputation']['registered']
      query = {}
      query['ID'] = "rb-reputation-#{node['hostname']}"
      query['Name'] = 'rb-reputation'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 7777
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-reputation']['registered'] = true
    end
    Chef::Log.info('rb-reputation service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['rb-reputation']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/rb-reputation-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-reputation']['registered'] = false
    end
    Chef::Log.info('rb-reputation service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
