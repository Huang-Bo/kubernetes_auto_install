#!/bin/bash
###########################################################
### Description: Docker  Install && configure  Scripts. ###
### Auther: Huang-Bo                                    ###
### Email: 17521365211@163.com                          ###
### Blog: https://blog.csdn.net/Habo_                   ###
### Create Date: 2022-07-15                             ###
###########################################################
#############################################################################################
# 颜色函数
#############################################################################################
function COLOR_RED() {
  echo -e "\033[1;31m$1\033[0m"
}

function COLOR_GREEN() {
  echo -e "\033[1;32m$1\033[0m"
}

function COLOR_YELLOW() {
  echo -e "\033[1;33m$1\033[0m"
}
#############################################################################################
# 文本颜色函数
#############################################################################################
function echo_check() {
  echo -e "$1  [\033[32m √ \033[0m]"
}

function log_success() {
  COLOR_GREEN "[SUCCESS] $1"
}

function log_error() {
  COLOR_RED "[ERROR] $1"
}
function log_info() {
  COLOR_YELLOW "[INFO] $1"
}

echo -e "\033[33m############################# step 1. Uninstall old version. ############################# \033[0m"
#############################################################################################
#卸载旧版本
#############################################################################################
sudo yum -y remove docker*
echo -e "\033[33m############################# step 2. Docker Install. ############################# \033[0m"
#############################################################################################
# 使用Docker安装脚本安装或yum源安装
#############################################################################################
if curl -sSL https://get.daocloud.io/docker | sh >/dev/null 2>&1; then
  log_success "Docker Install Success."
  if systemctl enable docker --now; then
    log_success " Docker Start Success."
  else
    log_error "Docker Start failed"
  fi
else
  yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  #安装docker
  yum install -y docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
  systemctl enable docker --now
fi
echo ""
echo ""
echo -e "\033[33m############################# step 3. configure Docker. ############################# \033[0m"
sudo mkdir -p /etc/docker
echo ""
echo ""
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://50cifzs5.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
echo ""
echo ""
sudo systemctl daemon-reload
sudo systemctl restart docker
