require 'pp'
#
# Cookbook Name:: memcached-custom
# Recipe:: install
#

ey_cloud_report "memcached" do
  message "Installing memcached"
end

is_memcached_instance = case node['memcached']['install_type']
when 'ALL_APP_INSTANCES'
  ['solo', 'app_master', 'app'].include?(node['dna']['instance_role'])
else
  (node['dna']['instance_role'] == 'util' && node['dna']['name'] == node['dna']['utility_name'])
end

if is_memcached_instance
  node['dna']['applications'].each do |app_name,data|
    user = node['dna']['users'].first

    template "/etc/conf.d/memcached" do
      source "memcached.erb"
      owner 'root'
      group 'root'
      mode 0644
      variables :memusage => node['memcached']['memusage'],
        :port     => 11211,
        :misc_opts => node['memcached']['misc_opts']
    end

    template '/etc/monit.d/memcached.monitrc' do
      source 'memcached.monitrc'
      owner 'root'
      group 'root'
      mode 0644
      notifies :run, 'execute[restart-monit]'
    end
  end
end
