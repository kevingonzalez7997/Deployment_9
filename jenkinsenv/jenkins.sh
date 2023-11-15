#!/bin/bash

sudo apt update 

sudo apt install -y openjdk-11-jre

# Add the required repos before installing jenkins

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# update system one more time before installing jenkins
sudo apt update

sudo apt install -y jenkins

sudo systemctl start jenkins