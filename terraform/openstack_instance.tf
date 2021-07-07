resource "openstack_compute_instance_v2" "vps" {  
    name = "Ansible Agent"  # name instance
    image_name = "CentOS-7"  # image name  
    flavor_name = "t1.medium" # (option for flavor_id) 
    key_pair = var.openstack_keypair  
    security_groups = [var.segroup] 
    network {    
        name = var.tenant_network
    }

    tags = ["ansible-agent-vps"]
 
    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.vps.network.0.fixed_ip_v4
        }

        source      = "./key/id_rsa.pub"
        destination = "~/id_rsa.pub"   
        on_failure = continue
    }

    provisioner "file" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.vps.network.0.fixed_ip_v4
        }

        source      = "./script/change_ssh_port.sh"
        destination = "~/change_ssh_port"   
        on_failure = continue
    }

    provisioner "remote-exec" {
        connection {
            user = var.ssh_user_name
            private_key = file(var.ssh_key_file)
            host = openstack_compute_instance_v2.vps.network.0.fixed_ip_v4
        }
         
        inline = [            
            "hostnamectl set-hostname isphone.ga",
            "cat /root/id_rsa.pub >> /root/.ssh/authorized_keys",
            "rm -rf ~/id_rsa.pub",
            "chmod 777 change_ssh_port",
            "~/change_ssh_port 2309", # Change ssh port to 2309
            "systemctl restart sshd",
            "rm -rf ~/change_ssh_port",
            "firewall-cmd --zone=public --add-port=2309/tcp --permanent",
            "firewall-cmd --reload"
        ]
    }

    # provisioner "local-exec" {
    #     command = "ansible-playbook -i ./hosts ansible-playbook.yml"
    #}

}

output "address" {
    value = openstack_compute_instance_v2.vps.network.0.fixed_ip_v4
    description = "IP Instance Openstack"
}


# Zabbix 
resource "openstack_compute_instance_v2" "zbx" {  
    name = "Zabbix"  # name instance
    image_name = "CentOS-7"  # image name  
    flavor_name = "t1.medium" # (option for flavor_id) 
    key_pair = var.openstack_keypair  
    security_groups = [var.segroup]  
    network {    
        name = var.tenant_network
    }

    tags = ["zabbix-vps"]
 
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
            "~/change_ssh_port 2309", # Change ssh port to 2309
            "systemctl restart sshd",
            "rm -rf ~/change_ssh_port",
            "firewall-cmd --zone=public --add-port=2309/tcp --permanent",
            "firewall-cmd --reload",
            "sh zabbix_install.sh"
        ]
    }

    # provisioner "local-exec" {
    #     command = "ansible-playbook -i ./hosts ansible-playbook.yml"
    #}

}

output "address" {
    value = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
    description = "IP Instance Openstack"
}
