output "zabbix-ip-address" {
    value = openstack_compute_instance_v2.zbx.network.0.fixed_ip_v4
    description = "IP Instance Openstack"
}

output "instance-ip-address" {
    value = openstack_compute_instance_v2.vps.*.network.0.fixed_ip_v4
    description = "IP Instance Openstack"
}


# data "aws_ebs_volume" "ebs_volume" {
#   most_recent = true

#   filter {
#     name   = "attachment.instance-id"
#     values = ["${aws_instance.DCOS-master3.id}"]
#   }
# }

# output "ebs_volume_id" {
#   value = "${data.aws_ebs_volume.ebs_volume.id}"
# }
