#!/bin/bash
###############################################
### Description: Config ipvs Scripts.       ###
### Auther: Huang-Bo                        ###
### Email: 17521365211@163.com              ###
### Blog: https://blog.csdn.net/Habo_       ###
### Create Date: 2022-07-14                 ###
###############################################
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
echo -e "\033[33m############################# step 1. Config ipvs ############################# \033[0m"
# source /etc/profile
modprobe -- ip_vs
modprobe -- ip_vs_sh
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- nf_conntrack_ipv4
sudo lsmod | grep ip_vs
echo ""
echo ""
line=$(lsmod | grep ip_vs -c)
if [ "$line" -gt 3 ]; then
  log_success "ipvs load successfully!"
else
  log_error "ipvs load failed!"
fi
