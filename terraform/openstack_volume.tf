resource "openstack_blockstorage_volume_v2" "volume_vps" {
  count = var.instance_number
  name = format("%s-%02d", var.volume_name, count.index+1)
  size = 20 
}

resource "openstack_compute_volume_attach_v2" "attached-vps" {
  count = var.instance_number
  instance_id = openstack_compute_instance_v2.vps[count.index].id
  volume_id = openstack_blockstorage_volume_v2.volume_vps[count.index].id
}

# create volume zbx 
resource "openstack_blockstorage_volume_v2" "volume_zbx" {
  name = "volume-zbx"
  size = 20 
}

resource "openstack_compute_volume_attach_v2" "attached-zbx" {
  instance_id = openstack_compute_instance_v2.zbx.id
  volume_id = openstack_blockstorage_volume_v2.volume_zbx.id
}

# search image centos7
data "openstack_images_image_v2" "centos7" {
  name          = "CentOS-7"
  most_recent   = true
}
