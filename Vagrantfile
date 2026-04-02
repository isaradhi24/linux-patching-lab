Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  # 1. GLOBAL: This script runs on EVERY VM to accept the Public Key
  pub_key = File.read(File.expand_path("../secrets/id_rsa.pub", __FILE__))
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    echo "#{pub_key}" | tee -a /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
  SHELL

  # 2. INVENTORY: Your specs
  NODES = {
    "ansible-controller" => { 
      box: "generic/ubuntu2004", ip: "192.168.57.10", port: 2222, mem: 2048, cpus: 2, script: "scripts/controller-setup.sh" 
    },
    "ubuntu-node1" => { 
      box: "generic/ubuntu2004", ip: "192.168.57.11", port: 2201, mem: 1024, cpus: 1, script: "scripts/node-setup.sh" 
    },
    "suse-node1" => { 
      box: "generic/opensuse15", ip: "192.168.57.12", port: 2202, mem: 1024, cpus: 1, script: "scripts/node-setup.sh" 
    },
    "jenkins-server" => { 
      box: "bento/ubuntu-22.04", ip: "192.168.57.20", port: 2280, mem: 2048, cpus: 2, script: "scripts/jenkins-setup.sh" 
    }
  }

  # 3. LOOP: Build the machines
  NODES.each do |name, opts|
    config.vm.define name do |node|
      node.vm.box = opts[:box]
      node.vm.hostname = name
      node.vm.network "private_network", ip: opts[:ip]
      node.vm.network "forwarded_port", guest: 22, host: opts[:port], auto_correct: true

      # PRIVATE KEY INJECTION: Only for the controller
      if name == "ansible-controller"
        node.vm.synced_folder ".", "/opt/ansible-lab", 
          owner: "vagrant", 
          group: "vagrant",
          mount_options: ["dmode=775", "fmode=664"]
          
        # Inject the Private Key so the Controller can "speak" to others
        node.vm.provision "file", 
          source: File.expand_path("../secrets/id_rsa", __FILE__), 
          destination: "/home/vagrant/.ssh/id_rsa"
        node.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
      end

      node.vm.provider "virtualbox" do |vb|
        vb.memory = opts[:mem]
        vb.cpus = opts[:cpus]
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      end

      node.vm.provision "shell", path: opts[:script]
    end
  end
end