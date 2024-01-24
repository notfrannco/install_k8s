#!/bin/bash
# check the docs for any install update info
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Requirements
# OS: Ubuntu 22.04 LTS
# run this script with sudo


# ENV vars
K8SVERSION=v1.28


cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
# The new repo "pkgs.k8s.io" is lock in a specific K8SVERSION specify
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8SVERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8SVERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt-get update
# the new repo pkgs.k8s.io is lock on the specific version specify, like $K8S=v1.28
# and it will install the latest 1.28 version
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# disable swap (k8s requeriment)
swapoff -a
sed -i 's/\/swap/#\/swap/' /etc/fstab

# Set iptables bridging
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
