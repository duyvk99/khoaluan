resource "openstack_compute_instance_v2" "vps" {  
    
    count = var.instance_number
    name = format("%s-%02d", var.instance_name, count.index+1)
    image_name = "CentOS-7"  # image name  
    flavor_name = "ECLOUD10" # (option for flavor_id) 
    key_pair = var.openstack_keypair  
    security_groups = [var.segroup]  
    network {    
        name = var.tenant_network
    }

    depends_on = [
    openstack_compute_secgroup_v2.segroup,
  ]

    tags = ["ansible-agent-vps"]
 
    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = self.network.0.fixed_ip_v4
        }

        source      = "./key/id_rsa.pub"
        destination = "~/id_rsa.pub"   
        on_failure = continue
    }

    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = self.network.0.fixed_ip_v4
        }

        source      = "./script/change_ssh_port.sh"
        destination = "~/change_ssh_port"   
        on_failure = continue
    }

    provisioner "remote-exec" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = self.network.0.fixed_ip_v4
        }
         
        inline = [
	    "cd ~",
            "hostnamectl set-hostname isphone.ga",
            "cat /root/id_rsa.pub >> /root/.ssh/authorized_keys",
            "rm -rf ~/id_rsa.pub",
            "chmod 777 change_ssh_port",
            "~/change_ssh_port 2309", # Change ssh port to 2309
            "systemctl restart sshd",
            "rm -rf ~/change_ssh_port",
            "firewall-cmd --zone=public --add-port=2309/tcp --permanent",
            "firewall-cmd --reload",
            "yum -y install git",
            # # Install zabbix agent 
            # "yum-config-manager --enable rhel-server-rhscl-7-rpms",
            # "rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm",
            # "yum install -y zabbix-agent",
            # # config zabbix agent
            # "systemctl enable zabbix-agent", 
            # "systemctl start zabbix-agent"
        ]
    }
}

# Zabbix
resource "openstack_compute_instance_v2" "zbx" {  
    name = "Zabbix Server"  
    image_name = "CentOS-7"  
    flavor_name = "ECLOUD10" 
    key_pair = var.openstack_keypair
    security_groups = [var.segroup]
    network {
        name = var.tenant_network
    }

    depends_on = [
        openstack_compute_secgroup_v2.segroup,
        openstack_compute_instance_v2.vps,
    ]

    tags = ["zabbix-vps"]
 
     # Bootable storage device containing the OS
    block_device {
        uuid                  = data.openstack_images_image_v2.centos7.id 
        source_type           = "image" 
        destination_type      = "local" 
        volume_size           = 20 
        boot_index            = 0  
        delete_on_termination = true 
    }
    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
        }

        source      = "./key/id_rsa.pub"
        destination = "~/id_rsa.pub"   
        on_failure = continue
    }

    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
        }

        source      = "./script/change_ssh_port.sh"
        destination = "~/change_ssh_port"   
        on_failure = continue
    }

    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
        }

        source      = "./script/zabbix_install.sh"
        destination = "~/zabbix_install.sh"   
        on_failure = continue
    }

    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
        }

        source      = "./template/nginx.conf"
        destination = "~/isphone.ga.conf"   
        on_failure = continue
    }

    provisioner "remote-exec" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
        }

        inline = [
            "hostnamectl set-hostname zabbix",
            "cat ~/id_rsa.pub >> ~/.ssh/authorized_keys",
            "rm -rf ~/id_rsa.pub",
            "chmod 777 change_ssh_port",
            "~/change_ssh_port 2309",
            "systemctl restart sshd",
            "rm -rf ~/change_ssh_port",
            "firewall-cmd --zone=public --add-port=2309/tcp --permanent",
            "firewall-cmd --reload",
            "sh zabbix_install.sh",
        ]
    }

}