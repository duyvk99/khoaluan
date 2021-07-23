variable "openstack_user_name" {    
    description = "The username for the Tenant."    
    type = string
    sensitive   = true

} 
variable "openstack_tenant_name" {    
    description = "The name of the Tenant."   
    type = string
    sensitive   = true

} 
variable "openstack_password" {    
    description = "The password for the Tenant." 
    type = string
    sensitive   = true
}
variable "openstack_auth_url" {
    description = "The endpoint url to connect to OpenStack."   
    type = string
    sensitive   = true 
} 
variable "openstack_keypair" {    
    description = "The keypair to be used."    
#    default  = "key" 
    default = "duykey"
} 
variable "tenant_network" {    
    description = "The network to be used."    
#    default  = "network" 
    default  = "WAN-1723"
}
variable "segroup" {    
    description = "Security Group."    
    default  = "web-group"
}

variable "ssh_user_name" {    
    description = "user ssh"    
    type = string
    sensitive   = true 
}
variable "ssh_key_file" {    
    description = "SSH key file."    
    type = string
    sensitive   = true 
}

variable "instance_number" {    
    description = "Instance number"    
    default  = 2
}

variable "instance_name" {    
    description = "Instance name"    
    default  = "Web Host"
}

variable "volume_name" {    
    description = "Volume name"    
    default  = "volume vps"
}
