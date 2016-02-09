# #
# # Cookbook Name:: sensu
# # Recipe:: sensu-client
# #
# # Copyright (c) 2015 The Authors, All Rights Reserved.
# #
# # Cookbook Name:: sensu-server
# # Recipe:: default
# #
# # Copyright (c) 2015 The Authors, All Rights Reserved.
# # 
# # Install and setup sensu-client
['sensu-plugin','redphone','net-ping'].each do |gems|
    gem_package gems do
       
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

# sensu_ip = search(:node, "announce:sensuserver")
# sensu_ip_address = sensu_ip.first[:ec2][:public_hostname]


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

template "/etc/sensu/conf.d/client.json" do
    source "client.json.erb"
    variables(:name => 'sensu-client',
              :address => '127.0.0.1',
              :subscriptions => 'ALL')
end

template "/etc/sensu/config.json" do
	source "client-config.json.erb"
	variables(:host => sensu_ip_address
			 )
end	

service 'sensu-client' do
    action [:start, :enable]
end
