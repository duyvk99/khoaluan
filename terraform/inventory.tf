resource "local_file" "iventory" {
  content = templatefile("./template/inventory.tpl",
    {
        public_ip =  openstack_compute_instance_v2.vps.*.network.0.fixed_ip_v4
    }
  )
  filename = "../ansible/hosts"
}

resource "local_file" "nginx-conf" {
  content = templatefile("./template/nginx.tpl",
    {
        public_ip =  openstack_compute_instance_v2.vps.*.network.0.fixed_ip_v4
    }
  )
  filename = "./template/nginx.conf"
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "cd ../ansible; ansible-playbook -i ./hosts ansible-playbook.yml"
    on_failure = continue
  }

    depends_on = [
    openstack_compute_instance_v2.vps,
  ]
}