#!/bin/bash
########################################
### Description: set yum source .    ###
### Auther: Huang-Bo                 ###
### Email: 17521365211@163.com       ###
### Blog: https://blog.csdn.net/Habo_###
### Create Date: 2022-07-13          ###
########################################
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
echo -e "\033[33m############################# 更换阿里云yum源.  ############################# \033[0m"
yum_dir="/etc/yum.repos.d/"
if [ -f $yum_dir"CentOS-Base.repo" ]; then
  mkdir -p ${yum_dir}old && mv ${yum_dir}C* ${yum_dir}old/
  if curl -o ${yum_dir}"CentOS-Base.repo" https://mirrors.aliyun.com/repo/Centos-7.repo; then
    if curl -o ${yum_dir}epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo; then
      yum clean all && yum makecache
      log_success "升级完成"
    else
      log_error "扩展包下载失败"
    fi
  else
    log_error "CentOS-Base.repo 下载失败"
  fi
else
  log_info "******CentOS-Base.repo file  exist******"
fi
echo ""
echo ""
