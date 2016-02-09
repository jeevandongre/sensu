include_recipe "apt"
include_recipe "rabbitmq"

# ['vim', 'git', 'tree','htop','ruby','ruby-dev'].each do |pkg|
#     package pkg do
#         action :install
#     end
# end

# ['redis-server'].each do |pkg|
#     package pkg do
#         action :install
#     end
# end


# remote_file 'erlang' do 
# 	source 'http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb'
# 	owner "ubuntu"
# 	group "ubuntu"
# 	mode "0755"
# end

# dpkg_package 'erlang-solutions_1.0_all.deb' do
# 	source 'erlang-solutions_1.0_all.deb'
# end


# execute 'apt-update' do
# 	command "sudo apt-get update"
# end

# apt_package "erlang-nox" do
# 	version "1:18.2"
# 	action :install
# end

# remote_file 'rabbitmq' do 
# 	source 'http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.0/rabbitmq-server_3.6.0-1_all.deb'
# 	owner "root"
# 	group "root"
# 	mode "0755"
# end

# dpkg_package 'rabbitmq-server' do
# 	source 'rabbitmq-server_3.6.0-1_all.deb'
# end

# execute "rabbitmq-update-rc" do
# 	command "sudo update-rc.d rabbitmq-server defaults"
# end

# service 'rabbitmq' do 
# 	action :start	
# end
	
rabbitmq_user "admin" do
    password "password"
    action :add
end

rabbitmq_user "admin" do
  vhost "/"
  permissions ".* .* .*"
  action :set_permissions
end

rabbitmq_user "admin" do
    vhost "/"
    tag " administrator"
    action :set_tags
end

rabbitmq_user "sensu" do
    password "password"
    action :add
end

rabbitmq_vhost "/sensu" do
    action :add
end

rabbitmq_user "sensu" do
    vhost "/sensu"
    permissions ".* .* .*"
    action :set_permissions
end

rabbitmq_user "sensu" do
    vhost "/sensu"
    tag " administrator"
    action :set_tags
end
