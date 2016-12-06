utility_nodes = node.dna['engineyard']['environment']['instances'].select{|i| ['util'].include?(i['role'])}.map {|i| {"ey-#{i['role']}-#{i['name']}".gsub(/-$/, '') => i['private_hostname']}}.each_with_object({}) { |el, h| el.each { |k, v| k='' if k.nil?; h[k].nil? ? h[k] = v : h[k] = (Array.new([h[k]]) << v).flatten } }

db_replicas = node.dna['engineyard']['environment']['instances'].select{|i| ['util'].include?(i['role'])}.map {|i| {"ey-#{i['role']}-#{i['name']}".gsub(/-$/, '') => i['private_hostname']}}.each_with_object({}) { |el, h| el.each { |k, v| k='' if k.nil?; h[k].nil? ? h[k] = v : h[k] = (Array.new([h[k]]) << v).flatten } }

db_master = node.db_master[0]

execute "Clean up ey-hosts entries from hosts file" do
  user "root"
  command "sed -i.bak '/#---EY-HOSTS-START/,/#---EY-HOSTS-END/d' /etc/hosts"
end


template "/etc/ey_hosts" do
  owner 'root'
  group 'root'
  mode 0644
  source "ey_hosts.erb"
  variables({
    :utility_nodes => utility_nodes,
    :db_replicas => db_replicas,
    :db_master => db_master
  })
end

execute "Setup /etc/ey_hosts1" do
  user "root"
  command <<-EOF
  echo '#{utility_nodes}' mor> /etc/ey_hosts1
  echo '#{db_replicas}' >> /etc/ey_hosts1
  echo '#{db_master}' >> /etc/ey_hosts1
  EOF
end

# append to /etc/hosts