#!/bin/bash
echo "-----------------install docker-----------------"
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker

sudo groupadd docker
sudo usermod -aG docker $USER

echo "-----------------install docker-compose-----------------"
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo groupadd docker-compose
sudo usermod -aG docker-compose $USER
sudo service docker restart

echo "-----------------DONE-----------------"