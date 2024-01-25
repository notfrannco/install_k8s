#!/bin/bash
# Check more info on other CRI in the doc
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# Requirements
# OS: Ubuntu 22.04 LTS
# run this script with sudo


### setting up container runtime prereq
cat <<- EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<- EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

# Apply sysctl params without reboot
sudo sysctl --system

# (Install containerd)
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo bash -c 'containerd config default > /etc/containerd/config.toml'
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
