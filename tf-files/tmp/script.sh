#!/bin/sh
sudo yum update -y

echo "Install Java JDK 8"
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk

echo "Install Jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins
sudo yum install -y nginx 
sudo usermod -a -G jenkins
sudo chkconfig jenkins on
sudo service nginx start && sudo service jenkins start
sleep 5

#sudo cat /var/lib/jenkins/secrets/initialAdminPassword