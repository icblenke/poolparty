$:.unshift("#{File.dirname(__FILE__)}/../lib")
require "rubygems"
require "poolparty"

pool "poolparty" do
  
  cloud "chef" do
    instances 1
    using :ec2
    chef_repo "basic/chef-repo"
    recipe "apache2"
    chef_attributes :apache2 => {:listen_ports => ["80", "8080"]}
    elastic_ip "192.129.218.49", "192.129.204.191"
    user_data <<-EOE
#!/bin/bash -x
echo "New User Data! ho."
    EOE
    security_group do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
    end
    
  end
end
