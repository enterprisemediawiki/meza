# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

if not File.file?("#{File.dirname(__FILE__)}/.vagrant/id_rsa")
  system("
    ssh-keygen -f \"./.vagrant/id_rsa\" -t rsa -N \"\" -C \"vagrant@vagrant\"
  ")
end

if File.file?("#{File.dirname(__FILE__)}/vagrantconf.yml")
  configuration = YAML::load(File.read("#{File.dirname(__FILE__)}/vagrantconf.yml"))
else
  configuration = YAML::load(File.read("#{File.dirname(__FILE__)}/vagrantconf.default.yml"))
end

if configuration.key?("baseBox") and configuration["baseBox"] == "debian"
  baseBox = "debian/contrib-stretch64"
else
  baseBox = "bento/centos-7.4"
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  #
  # CONFIGURE SECOND SERVER IF envtype == 2app
  # envtype=2app vagrant up
  #
  if configuration.key?("app2")

    config.vm.define "app2" do |app2|

      app2.vm.box = baseBox
      app2.vm.hostname = 'app2'

      app2.vm.network :private_network, ip: "192.168.56.57"

      app2.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ['modifyvm', :id, '--cableconnected1', 'on']
        v.customize ["modifyvm", :id, "--memory", configuration["app2"]["memory"] ]
        v.customize ["modifyvm", :id, "--cpus", configuration["app2"]["cpus"] ]
        v.customize ["modifyvm", :id, "--name", "app2"]
      end

      # Non-controlling server should not have meza
      app2.vm.synced_folder ".", "/vagrant", disabled: true
   	  # app2.vm.synced_folder ".", "/opt/meza", type: "rsync",
      #   rsync__args: ["--verbose", "--archive", "--delete", "-z"]

      # Transfer setup-minion-user.sh script to app2
      app2.vm.provision "file", source: "./src/scripts/ssh-users/setup-minion-user.sh", destination: "/tmp/minion.sh"
      app2.vm.provision "file", source: "./.vagrant/id_rsa.pub", destination: "/tmp/meza-ansible.id_rsa.pub"

      #
      # Setup SSH user and unsafe testing config
      #
      app2.vm.provision "minion-ssh", type: "shell", preserve_order: true, binary: true, inline: <<-SHELL
        if [ ! -f /opt/conf-meza/public/public.yml ]; then

          bash /tmp/minion.sh

          # Turn off host key checking for user meza-ansible, to avoid prompts
          echo "setup .ssh/config"
          bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /opt/conf-meza/users/meza-ansible/.ssh/config'
          sudo chown meza-ansible:meza-ansible /opt/conf-meza/users/meza-ansible/.ssh/config
          sudo chmod 600 /opt/conf-meza/users/meza-ansible/.ssh/config

          # Allow password auth
          echo "setup sshd_config password auth"
          sed -r -i 's/PasswordAuthentication no/PasswordAuthentication yes/g;' /etc/ssh/sshd_config
          systemctl restart sshd
        fi
      SHELL
    end

  end

  # FIXME #830: Gross...copy-paste of above
  if configuration.key?("db2")

    config.vm.define "db2" do |db2|

      db2.vm.box = baseBox
      db2.vm.hostname = 'db2'

      db2.vm.network :private_network, ip: "192.168.56.58"

      db2.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ['modifyvm', :id, '--cableconnected1', 'on']
        v.customize ["modifyvm", :id, "--memory", configuration["db2"]["memory"] ]
        v.customize ["modifyvm", :id, "--cpus", configuration["db2"]["cpus"] ]
        v.customize ["modifyvm", :id, "--name", "db2"]
      end

      # Non-controlling server should not have meza
      db2.vm.synced_folder ".", "/vagrant", disabled: true
      # db2.vm.synced_folder ".", "/opt/meza", type: "rsync",
      #   rsync__args: ["--verbose", "--archive", "--delete", "-z"]

      # Transfer setup-minion-user.sh script to db2
      db2.vm.provision "file", source: "./src/scripts/ssh-users/setup-minion-user.sh", destination: "/tmp/minion.sh"
      db2.vm.provision "file", source: "./.vagrant/id_rsa.pub", destination: "/tmp/meza-ansible.id_rsa.pub"

      #
      # Setup SSH user and unsafe testing config
      #
      db2.vm.provision "minion-ssh", type: "shell", preserve_order: true, binary: true, inline: <<-SHELL
        if [ ! -f /opt/conf-meza/public/public.yml ]; then

          bash /tmp/minion.sh

          # Turn off host key checking for user meza-ansible, to avoid prompts
          echo "setup .ssh/config"
          bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /opt/conf-meza/users/meza-ansible/.ssh/config'
          sudo chown meza-ansible:meza-ansible /opt/conf-meza/users/meza-ansible/.ssh/config
          sudo chmod 600 /opt/conf-meza/users/meza-ansible/.ssh/config

          # Allow password auth
          echo "setup sshd_config password auth"
          sed -r -i 's/PasswordAuthentication no/PasswordAuthentication yes/g;' /etc/ssh/sshd_config
          systemctl restart sshd
        fi
      SHELL
    end

  end

  config.vm.define "app1", primary: true do |app1|

    # app1.vm.box = "centos/7"
    app1.vm.box = baseBox
    # app1.vm.box = "geerlingguy/centos7"
    app1.vm.hostname = 'app1'
    # app1.vm.box_url = "ubuntu/precise64"

    app1.vm.network :private_network, ip: "192.168.56.56"

    app1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ['modifyvm', :id, '--cableconnected1', 'on']
      v.customize ["modifyvm", :id, "--memory", configuration["app1"]["memory"] ]
      v.customize ["modifyvm", :id, "--cpus", configuration["app1"]["cpus"] ]
      v.customize ["modifyvm", :id, "--name", "app1"]
    end

    # Disable default synced folder at /vagrant, instead put at /opt/meza
    app1.vm.synced_folder ".", "/vagrant", disabled: true
    app1.vm.synced_folder ".", "/opt/meza", type: "virtualbox", owner: "vagrant", group: "vagrant", mount_options: ["dmode=755,fmode=755"]

    # app1.vm.synced_folder ".", "/opt/meza", type: "smb"
    # app1.vm.synced_folder ".", "/opt/meza", type: "rsync",
    #   rsync__args: ["--verbose", "--archive", "--delete", "-z"]


    # Transfer keys to app1
    app1.vm.provision "file", source: "./.vagrant/id_rsa", destination: "/tmp/meza-ansible.id_rsa"
    app1.vm.provision "file", source: "./.vagrant/id_rsa.pub", destination: "/tmp/meza-ansible.id_rsa.pub"


    #
    # Bootstrap meza on the controlling VM
    #
    app1.vm.provision "getmeza", type: "shell", preserve_order: true, inline: <<-SHELL
      bash /opt/meza/src/scripts/getmeza.sh
      rm -rf /opt/conf-meza/users/meza-ansible/.ssh/id_rsa
      rm -rf /opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub
      mv /tmp/meza-ansible.id_rsa /opt/conf-meza/users/meza-ansible/.ssh/id_rsa
      mv /tmp/meza-ansible.id_rsa.pub /opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub

      chmod 600 /opt/conf-meza/users/meza-ansible/.ssh/id_rsa
      chown meza-ansible:meza-ansible /opt/conf-meza/users/meza-ansible/.ssh/id_rsa
      chmod 644 /opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub
      chown meza-ansible:meza-ansible /opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub

      cat /opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub >> /opt/conf-meza/users/meza-ansible/.ssh/authorized_keys
    SHELL

    #
    # Setup meza environment, either monolithic, with 2 app servers, and/or 2 db servers
    #
    envvars = {}
    if configuration.key?("app2") || configuration.key?("db2")
      envvars[:default_servers] = "192.168.56.56"
    end

    if configuration.key?("app2")
      envvars[:app_servers] = "192.168.56.56,192.168.56.57"
    end

    if configuration.key?("db2")
      envvars[:db_master] = "192.168.56.56"
      envvars[:db_slaves] = "192.168.56.58"
    end

    # Create vagrant environment if it doesn't exist
    app1.vm.provision "setupenv", type: "shell", preserve_order: true, env: envvars, inline: <<-SHELL
      if [ ! -d /opt/conf-meza/secret/vagrant ]; then
        meza setup env vagrant --fqdn=192.168.56.56 --db_pass=1234 --private_net_zone=public
      fi
    SHELL

    #
    # Setup meza public config
    #
    app1.vm.provision "publicconfig", type: "shell", preserve_order: true, inline: <<-SHELL
      # Create public config dir if not exists
      [ -d /opt/conf-meza/public ] || mkdir /opt/conf-meza/public

      # If public config YAML file not present, create with defaults
      if [ ! -f /opt/conf-meza/public/public.yml ]; then
cat >/opt/conf-meza/public/public.yml <<EOL
---
blender_landing_page_title: Meza Wikis
m_setup_php_profiling: true
m_force_debug: true

sshd_config_UsePAM: "no"
sshd_config_PasswordAuthentication: "yes"
EOL
      fi

      # Make the vagrant environment configured for development
      echo 'm_use_production_settings: False' >> /opt/conf-meza/public/public.yml

      cat /opt/conf-meza/public/public.yml
    SHELL

    #
    # If multi-app: turn off hostkey checking
    #
    if configuration.key?("app2") || configuration.key?("db2")

      app1.vm.provision "keytransfer", type: "shell", preserve_order: true, inline: <<-SHELL

        # Turn off host key checking for user meza-ansible, to avoid prompts
        bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /opt/conf-meza/users/meza-ansible/.ssh/config'
        sudo chown meza-ansible:meza-ansible /opt/conf-meza/users/meza-ansible/.ssh/config
        sudo chmod 600 /opt/conf-meza/users/meza-ansible/.ssh/config

        # Allow SSH login
        # WARNING: This is INSECURE and for test environment only
        sed -r -i 's/UsePAM yes/UsePAM no/g;' /etc/ssh/sshd_config
        systemctl restart sshd

        # FIXME $818: Stuff below would be more secure if it worked

        # echo "switch user"
        # sudo su meza-ansible

        # Copy id_rsa.pub to each minion
        # sshpass -p 1234 ssh meza-ansible@192.168.56.57 "echo \"$pubkey\" >> /opt/conf-meza/users/meza-ansible/.ssh/authorized_keys"

        # Remove password-based authentication for $ansible_user
        #echo "delete password"
        #ssh 192.168.56.57 "sudo passwd --delete meza-ansible"

        # Allow SSH login
        # WARNING: This is INSECURE and for test environment only
        # echo "setup sshd_config"
        # ssh 192.168.56.57 "sudo sed -r -i 's/UsePAM yes/UsePAM no/g;' /etc/ssh/sshd_config && sudo systemctl restart sshd"
      SHELL

      # else

      #
      # Finally: Deploy if not multi-server
      #
      # app1.vm.provision "deploy", type: "shell", preserve_order: true, inline: <<-SHELL
      #   meza deploy vagrant
      # SHELL
    end

  end

end
