#!/usr/bin/env bash
hostnamectl set-hostname minion1

setenforce 0

yum -y install git

##Get rpm and install
#git clone https://github.com/xingangwang/k8s-rpm.git
yum install -y docker
#yum install -y k8s-rpm/*.rpm

#yum install -y docker kubelet kubeadm kubectl kubernetes-cni ebtables

systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
systemctl disable firewalld

##Use accelerator of Aliyun docker hub
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://8vzilohj.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker


images=(pause-amd64:3.0 kube-proxy-amd64:v1.5.5  kube-dnsmasq-amd64:1.4 exechealthz-amd64:1.2
 kubedns-amd64:1.9 dnsmasq-metrics-amd64:1.0)
for imageName in ${images[@]} ; do
  docker pull registry.cn-hangzhou.aliyuncs.com/accenture_ctag/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/accenture_ctag/$imageName gcr.io/google_containers/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/accenture_ctag/$imageName
done


