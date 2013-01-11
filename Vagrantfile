# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Check https://github.com/mitchellh/vagrant/issues/713
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/openspending", "1"]
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/openspendingjs", "1"]
  # Check https://github.com/mitchellh/vagrant/issues/516
  config.vm.customize(["modifyvm", :id, "--nictype1", "Am79C973"])

  config.vm.customize do |vm|
    vm.memory_size = 1024
  end

  config.vm.forward_port 8983, 8983
  config.vm.forward_port 5000, 5000

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "user" => "vagrant",
      "postgresql" => {
        "ssl" => false
      }
    }
    chef.add_recipe("apt")
    chef.add_recipe("ckan")
  end

end
