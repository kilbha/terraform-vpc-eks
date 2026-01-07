#! /bin/sh

sudo apt update
sudo apt install fontconfig openjdk-21-jre -y
java -version


sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y


sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker

sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart jenkins
sudo chmod 777 /var/run/docker.sock


docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community


# 1. Install dependencies
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

# 2. Add the Aqua Security GPG key and repository
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# 3. Update package list and install Trivy
sudo apt-get update -y
sudo apt-get install trivy -y

# 4. Update package and install aws cli
sudo apt update
sudo apt install unzip


echo "########INSTALLING AWS CLI###############"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

aws --version