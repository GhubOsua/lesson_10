# -*- mode: ruby -*-
# vim: set ft=ruby :
ENV["LC_ALL"] = "en_US.UTF-8"


Vagrant.configure("2") do |config|
config.vm.box = "generic/centos8"
config.vm.hostname = "lesson10"
	#config.vm.network "private_network", ip: "192.168.11.150"
	config.vm.provision "shell", path: "lesson_10.sh"
	config.vm.define "lesson10"
	config.vm.provider "virtualbox" do |vb|
		vb.gui=false
		vb.memory = 2048
		vb.cpus = 2
		#vb.customize ['createhd', '--filename', disk, '--size', 1 * 1024]
		#vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
		#vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
               end

	config.vm.synced_folder "/home/s1steel/Документы/git_otus/lesson_10", "/vagrant", type: "rsync"
	#config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
	config.vm.provision "shell", path: "lesson_10.sh"
end
