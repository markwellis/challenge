VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "debian/jessie64"

    #versions newer than this use rsync to share the vagrant folder. not cool
    config.vm.box_version = '8.2.1'

    config.vm.provision "shell",
        path: "vagrant/setup.sh",
        privileged: false
end
