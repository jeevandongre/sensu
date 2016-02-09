
# Setup Rabbitmq
#  
include_recipe "uchiwa"

node.set[:announce][:sensuserver] = true
node.save


# Basic apt packages to be installed.

['build-essential', 'zlib1g-dev', 'libreadline-dev','libssl-dev', 'libcurl4-openssl-dev','g++','vim', 'git', 'tree','htop','ruby','ruby-dev','ruby1.9.1-dev'].each do |pkg|
    package pkg do
        action :install
    end
end

# Installing sensu gems.

['sensu-plugin','redphone','net-ping'].each do |gems|
    gem_package gems do
       
        action :install
    end
end    

# Installing sensu package.

apt_repository 'sensu' do
     uri 'http://repos.sensuapp.org/apt'
     components ['main']
     key 'http://repos.sensuapp.org/apt/pubkey.gpg'
     action :add
 end

apt_package 'sensu' do
    action :install
end

# Configuring SSL Certifications.

directory "/etc/sensu/ssl" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

# Configuring rabbitmq for sensu

template "/etc/sensu/conf.d/rabbitmq.json" do
    source "rabbitmq.json.erb"
    variables(:cert => '/etc/sensu/ssl/cert.pem', 
              :key => '/etc/sensu/ssl/key.pem', 
              :host => 'localhost', 
              :port => 5671 , 
              :vhost => '/sensu', 
              :user => 'sensu', 
              :pass => 'password')
end

# Installing rabbitmq, redis and erlang.

apt_repository 'rabbitmq-server' do
    uri 'http://www.rabbitmq.com/debian/'
    components ['main']
    distribution 'testing'
    key 'http://www.rabbitmq.com/rabbitmq-signing-key-public.asc'
    action :add
    deb_src true
end

['rabbitmq-server', 'erlang-nox','redis-server'].each do |pkg|
    package pkg do
        action :install
    end
end

# Rabbitmq user configuration.

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

directory "/etc/rabbitmq/ssl" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

directory '/etc/sensu/ssl/' do
    owner 'root'
    group 'root'
    mode  '0755'
    action :create
end

directory '/etc/sensu/conf.d/' do
    owner 'root'
    group 'root'
    mode  '0755'
    action :create
end

directory '/etc/sensu/plugins/' do
    owner 'root'
    group 'root'
    mode  '0755'
    action :create
end

directory '/etc/sensu/handlers/' do
    owner 'root'
    group 'root'
    mode  '0755'
    action :create
end

# Configuration of ssl certifications.


cookbook_file "ssl_certs/sensu_ca/cacert.pem" do
    source "ssl_certs/sensu_ca/cacert.pem"
    path "/etc/rabbitmq/ssl/cacert.pem"
    action :create
end

cookbook_file "ssl_certs/server/cert.pem" do
    source "ssl_certs/server/cert.pem"
    path "/etc/rabbitmq/ssl/cert.pem"
    action :create
end

cookbook_file "ssl_certs/server/key.pem" do
    source "ssl_certs/server/key.pem" 
    path "/etc/rabbitmq/ssl/key.pem"
    action :create
end

service 'rabbitmq-server' do
    action [:enable, :start]
end

template "/etc/rabbitmq/rabbitmq.config" do
    source "rabbit.erb"
    variables(:port => 5671,
              :ca_cert => '/etc/rabbitmq/ssl/cacert.pem',
              :cert => '/etc/rabbitmq/ssl/cert.pem',
              :key => '/etc/rabbitmq/ssl/key.pem')
    notifies :restart, 'service[rabbitmq-server]', :immediately
end


template "/etc/sensu/conf.d/redis.json" do
    source "redis.json.erb"
    variables(:host => 'localhost',
             :port => 6379)
end

template "/etc/sensu/conf.d/api.json" do
    source "api.json.erb"
    owner   "root"
    group   "root"
    mode    "0755"
end
    
cookbook_file "ssl_certs/client/cert.pem" do
    source "ssl_certs/client/cert.pem"
    path "/etc/sensu/ssl/cert.pem"
    action :create
end

cookbook_file "ssl_certs/client/key.pem" do
    source "ssl_certs/client/key.pem"
    path "/etc/sensu/ssl/key.pem"
    action :create
end

template "/etc/sensu/handlers/pagerduty.rb" do
    source "pagerduty.rb.erb"
    mode '0755'
    owner 'root'
    group 'root'
end

template "/etc/sensu/conf.d/notification.json" do
    source "notification.json.erb"
    mode    "0755"
    owner   "root"
    group   "root"
end

template "/etc/sensu/conf.d/handler_notification.json" do
    source "handler_notification.json.erb"
    mode   "0755"
    owner  "root"
    group "root"
end

execute "rabbitmq-web-console" do
    command "sudo rabbitmq-plugins enable rabbitmq_management"
end

template "/etc/sensu/plugins/check-ping.rb" do
    source "check-ping.rb.erb"
    mode '0755'
    owner 'root'
    group 'root'
end    

template "/etc/sensu/conf.d/check_ping.json" do
    source "check_ping.json.erb"
    owner  "root"
    group  "root"
    mode   "0755"
end    


service 'redis-server' do
    action [:enable, :start]
end

service 'sensu-server' do
    action [:start]
end

service 'sensu-api' do
    action [:enable, :start]
end    

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


