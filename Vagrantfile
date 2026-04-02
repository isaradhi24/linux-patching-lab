Vagrant.configure("2") do |config|

  # ==========================================
  # 1. GLOBAL CONFIG BLOCK
  # ==========================================
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  # READ KEYS FROM WINDOWS FOLDER
  # Master key for Ansible Controller to talk to Nodes
  master_pub_key = File.read(File.expand_path("../secrets/id_rsa.pub", __FILE__))
  # New key for Jenkins to talk to Controller
  jenkins_pub_key = File.read(File.expand_path("../secrets/jenkins_id_rsa.pub", __FILE__))

  # ==========================================
  # 2. GLOBAL PROVISIONING (Runs on ALL VMs)
  # ==========================================
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    # Add Master Key
    echo "#{master_pub_key}" >> /home/vagrant/.ssh/authorized_keys
    # Add Jenkins Key (so Jenkins can SSH into any node if needed)
    echo "#{jenkins_pub_key}" >> /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
  SHELL

  # ==========================================
  # 3. INVENTORY DEFINITION BLOCK
  # ==========================================
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

  # ==========================================
  # 4. DEPLOYMENT LOOP BLOCK
  # ==========================================
  NODES.each do |name, opts|
    config.vm.define name do |node|
      node.vm.box = opts[:box]
      node.vm.hostname = name
      node.vm.network "private_network", ip: opts[:ip]
      node.vm.network "forwarded_port", guest: 22, host: opts[:port], auto_correct: true

      # ------------------------------------------
      # 4a. CONTROLLER-SPECIFIC BLOCK
      # ------------------------------------------
      if name == "ansible-controller"
        node.vm.synced_folder ".", "/opt/ansible-lab", 
          owner: "vagrant", group: "vagrant", mount_options: ["dmode=775", "fmode=664"]
          
        # Inject Master Private Key (Controller -> Nodes)
        node.vm.provision "file", 
          source: File.expand_path("../secrets/id_rsa", __FILE__), 
          destination: "/home/vagrant/.ssh/id_rsa"
        node.vm.provision "shell", inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
      end

      # ------------------------------------------
      # 4b. JENKINS-SPECIFIC BLOCK
      # ------------------------------------------
      if name == "jenkins-server"
        # Inject Jenkins Private Key (Jenkins -> Controller)
        # We place it in /var/lib/jenkins so the 'jenkins' user can see it
        node.vm.provision "shell", inline: <<-SHELL
          mkdir -p /var/lib/jenkins/.ssh
          cp /vagrant/secrets/jenkins_id_rsa /var/lib/jenkins/.ssh/id_rsa
          chmod 600 /var/lib/jenkins/.ssh/id_rsa
          chown -R jenkins:jenkins /var/lib/jenkins/.ssh
        SHELL
      end

      # ------------------------------------------
      # 4c. PROVIDER (VIRTUALBOX) BLOCK
      # ------------------------------------------
      node.vm.provider "virtualbox" do |vb|
        vb.memory = opts[:mem]
        vb.cpus = opts[:cpus]
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      end

      # ------------------------------------------
      # 4d. FINAL SHELL PROVISIONING
      # ------------------------------------------
      node.vm.provision "shell", path: opts[:script]
    end
  end
end