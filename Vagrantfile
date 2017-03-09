# -*- mode: ruby -*-
# vi: set ft=ruby :

# read the env
require 'json'
begin
  file = File.read('env.json')
  data = JSON.parse(file)
rescue
  puts "no env.json provided"
  Process.kill 9, Process.pid
end

# defaults
unless data.has_key?("subnet") 
  data["subnet"] = "192.168.10"
end
unless data.has_key?("numberOfNodes") 
  data["numberOfNodes"] = "192.168.10"
end
unless data.has_key?("aws_data_type") 
  data["aws_data_type"] = "json"
end
unless data.has_key?("aws_region") 
  data["aws_region"] = "eu-west-1"
end

unless data.has_key?("aws_secret_key") and data.has_key?("aws_access_key")
  puts "aws_secret_key and aws_access_key are mandatory"
  Process.kill 9, Process.pid
end

numberOfNodes=data["numberOfNodes"].to_i
if numberOfNodes < 1
  numberOfNodes = 1
  puts "numberOfNodes set to 1 as value provided < 1"
elsif numberOfNodes > 10
  numberOfNodes = 10
  puts "numberOfNodes set to 10 as value provided > 10"
end
data["numberOfNodes"] = numberOfNodes.to_s

file = File.write('env.runtime.json', data.to_json)

$HOSTFILE = <<EOF
# Create python script
cat << PYTHON > createhostfile.py
import json
with open('/vagrant/env.runtime.json') as data_file:    
  data = json.load(data_file)
numberOfNodes=int(data["numberOfNodes"])
print "Number of nodes: "+str(numberOfNodes)
subnet=data["subnet"]
f = open('/etc/hosts', 'w')
f.write('127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4\\n')
f.write('::1 localhost localhost.localdomain localhost6 localhost6.localdomain6\\n')
for x in range(1,numberOfNodes+1):
  f.write(subnet+'.'+str(10+x)+' node'+str(x)+' node'+str(x)+'.test\\n')
f.close()
PYTHON
python createhostfile.py
rc=$?
rm -f createhostfile.py
exit $rc
EOF

$NODE_SCRIPT = <<EOF
echo "Preparing node..."

# ensure the time is up to date
apt-get update
apt-get -y install ntp
service ntp stop
ntpdate -s time.nist.gov
service ntp start

apt-get -y install build-essential curl git unzip

if [ ! -e awscli-bundle.zip ]; then
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
fi
# Note that version is written to STDERR
aws --version 2>&1 | grep aws-cli
if [ "$?" != 0 ]; then
  unzip awscli-bundle.zip
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
fi

# installed now?
aws --version 2>&1 | grep aws-cli
if [ "$?" != 0 ]; then
  echo "AWS CLI failed to install"
  exit 1
fi

# Create a config file
if [ ! -e "~vagrant/.aws/credentials" ]; then

# Create python script
cat << PYTHON > createawsconfig.py
import json
from os.path import expanduser
with open('/vagrant/env.runtime.json') as data_file:    
  data = json.load(data_file)
awsSecret=data["aws_secret_key"]
awsAccess=data["aws_access_key"]
awsRegion=data["aws_region"]
awsData=data["aws_data_type"]
home=expanduser("~vagrant")
f = open(home+'/.aws/credentials', 'w')
f.write('[default]\\n')
f.write('aws_access_key_id = '+awsAccess+'\\n')
f.write('aws_secret_access_key = '+awsSecret)
f.close()
f = open(home+'/.aws/config', 'w')
f.write('[default]\\n')
f.write('region = '+awsRegion+'\\n')
f.write('output = '+awsData)
f.close()
PYTHON

mkdir ~vagrant/.aws
python createawsconfig.py
su - vagrant -c "aws iam get-user 2>&1" | grep "Arn"
if [ "$?" != "0" ]; then
  echo "AWS configuration failed"
  exit 1
fi
rm -f createawsconfig.py

fi

EOF



def set_hostname(server)
  server.vm.provision 'shell', inline: "hostname #{server.vm.hostname}"
end
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "node1" do |node|
    node.vm.network "private_network", ip: data["subnet"]+".10"
	node.vm.hostname = "aws-test.test"
	set_hostname(node)
    node.vm.provision :shell, inline: $NODE_SCRIPT
	node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", "512"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end

  end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
