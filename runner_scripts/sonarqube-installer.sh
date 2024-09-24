#!/bin/bash
sudo apt-get update

## Install Docker
yes | sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
echo "Waiting for 30 seconds before runing Sonarqube Docker container..."
sleep 30

## Runing Sonarqube in a docker container 
docker run -d -p 9000:9000 --name sonarqube-container sonarqube:lts-community