utility_nodes = @node.dna['utility_instances']
db_replicas = @node.dna['db_slaves']
db_master = @node.db_master

execute "Clean up ey-hosts entries from hosts file" do
  user "root"
  command "sed -i.bak '/#---EY-HOSTS-START/,/#---EY-HOSTS-END/d' /etc/hosts"
end


execute "Setup /etc/ey_hosts" do
  user "root"
  command "echo '#---EY-HOSTS-START' > /etc/ey_hosts
  echo '#{utility_nodes}' >> /etc/ey_hosts
  echo '#{db_replicas}' >> /etc/ey_hosts
  echo '#{db_master}' >> /etc/ey_hosts
  echo '#---EY-HOSTS-END"
end

# append to /etc/hosts