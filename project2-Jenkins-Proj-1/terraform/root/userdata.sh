#! /usr/bin/env bash

sudo apt update && sudo apt upgrade -y
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins.service 
sudo apt install docker.io
usermod -aG docker jenkins
usermod -aG docker root
systemctl restart docker
sudo apt autoremove
sudo apt remove
sudo apt autoclean
sudo apt clean
