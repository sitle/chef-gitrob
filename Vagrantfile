# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'gitrob'
  config.omnibus.chef_version = '11.16.4'
  config.vm.box = 'ubuntu-14.04-chef'
  config.vm.network :private_network, ip: '172.28.128.13'
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      gitrob: {
        accept_agreement: true,
        tokens: [''],
        organizations: ['']
      }
    }

    chef.run_list = [
      'recipe[gitrob::default]'
    ]
  end
end
