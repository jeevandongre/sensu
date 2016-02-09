# #
# # Cookbook Name:: sensu-server
# # Recipe:: default
# #
# # Copyright (c) 2015 The Authors, All Rights Reserved.
  
# # Setup Rabbitmq
# #  

['vim', 'git', 'tree','htop'].each do |pkg|
    package pkg do
        action :install
    end
end

apt_repository 'sensu' do
     uri 'http://repos.sensuapp.org/apt'
     components ['sensu',  'main']
     key 'http://repos.sensuapp.org/apt/pubkey.gpg'
     action :add
 end

apt_package 'sensu' do
    action :install
end

directory "/etc/sensu/ssl" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

# sensu = search(:node, "announce:sensuserver")
# sensu_ip_address = sensu.first[:ec2][:public_hostname]

template "/etc/sensu/conf.d/rabbitmq.json" do
    source "rabbitmq.json.erb"
    owner  "sensu"
    group  "sensu"
    mode   "0755"
    variables(:cert => '/etc/sensu/ssl/cert.pem', 
              :key => '/etc/sensu/ssl/key.pem', 
              :host => sensu_ip_address,
              :port => 5671 , 
              :vhost => '/sensu', 
              :user => 'sensu', 
              :pass => 'password'
             )
end
