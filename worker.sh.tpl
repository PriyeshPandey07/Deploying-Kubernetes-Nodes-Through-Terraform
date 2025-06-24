#!/bin/bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo  sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum update -y
sudo yum install httpd -y 
sudo systemctl start httpd
sudo systemctl enable httpd


sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker


sudo containerd config default > /etc/containerd/config.toml 
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd


sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


# Update package list
sudo yum update -y
# Add a new repository (example: Kubernetes repository)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install Kubernetes packages (example)
sudo yum clean all
sudo yum update -y  
sudo yum install kubelet kubeadm kubectl -y --disableexcludes=kubernetes

# Enable and start kubelet service
sudo systemctl start --now kubelet
sudo systemctl enable --now kubelet

# Wait for join-command to be served by master, then join


# Execute the join command
sudo bash /root/join-command.sh