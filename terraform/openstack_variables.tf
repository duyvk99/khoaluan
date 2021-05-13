variable "openstack_user_name" {    
    description = "The username for the Tenant."    
#   default  = "username" 
    default = "duyvk"
} 
variable "openstack_tenant_name" {    
    description = "The name of the Tenant."   
#     default  = "username"
    default = "duyvk"
} 
variable "openstack_password" {    
    description = "The password for the Tenant." 
#    default  = "Password"
    default = "Duy!@#123" 
}
variable "openstack_auth_url" {
    description = "The endpoint url to connect to OpenStack."   
#    default  = "https://controller:5000/v3/"
    default  = "http://controller:5000/v3/" 
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
variable "ssh_user_name" {    
    description = "The network to be used."    
#    default  = "network" 
    default  = "root"
}
variable "ssh_key_file" {    
    description = "The network to be used."    
#    default  = "network" 
    default  = "/root/.ssh/duy"
}

variable "segroup" {    
    description = "Security Group."    
    default  = "Web-Security-Group"
}
