[webserver]
%{ for ip in public_ip ~}
server-${ip} ansible_host=${ip} ansible_user=root ansible_port=2309 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}