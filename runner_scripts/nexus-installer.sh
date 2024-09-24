#!/bin/bash
sudo apt-get update

## Install Docker
yes | sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
echo "Waiting for 30 seconds before runing Nexus Docker container..."
sleep 30

## Runing Nexus in a docker container 
docker run -d -p 8081:8081 --name nexus-container sonatype/nexus3:latest