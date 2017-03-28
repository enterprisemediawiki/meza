# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # config.vm.define "monolith" do |web|
  #   web.vm.box = "precise64"
  #   web.vm.hostname = 'web'
  #   web.vm.box_url = "ubuntu/precise64"

  config.vm.box = "centos/7"

  config.vm.network :private_network, ip: "192.168.56.56"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 1
  end

  # Disable default synced folder at /vagrant, instead put at /opt/meza
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/opt/meza", type: "rsync",
    rsync__args: ["--verbose", "--archive", "--delete", "-z"]


  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.vm.provision "setup", type: "shell", inline: <<-SHELL
    bash /opt/meza/src/scripts/getmeza.sh
  SHELL

  # Default is to run `meza deploy` command. Add environment variable to override
  if not ENV["deploy"] || ENV["deploy"] == "basic"

    config.vm.provision "deploy", type: "shell", inline: <<-SHELL
      meza setup env monolith --fqdn=192.168.56.56 --db_pass=1234 --enable_email=true
      meza deploy monolith
    SHELL

  # Could have option to get test configs enterprisemediawiki/meza-test-config
  # and enterprisemediawiki/meza-test-config-secret, and backups from
  # jamesmontalvo3/meza-test-backups, to bootstrap a test config. Also could
  # have more involved installations with many well-developed wikis showcasing
  # what is possible.
  # elsif ENV["deploy"] == "test"

  end

end
