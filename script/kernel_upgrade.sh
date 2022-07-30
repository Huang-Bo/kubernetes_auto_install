#!/bin/bash
#############################################
### Description: Font color settings.     ###
### Auther: Huang-Bo                      ###
### Email: 17521365211@163.com            ###
### Blog: https://blog.csdn.net/Habo_     ###
### Create Date: 2022-07-13               ###
#############################################
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
#############################################################################################
# 获取系统信息并输出
#############################################################################################
LINE="**************************************************************************************"
KERNEL_DIR="/etc/redhat-release"
CPU_DIR="/proc/cpuinfo"
function PRINT_SYSTEM_INFO() {
  SYSTEM_DATE=$(/usr/bin/date)
  SYSTEM_VERSION=$(cat ${KERNEL_DIR})
  SYSTEM_CPU=$(cat ${CPU_DIR} | grep 'model name' | head -1 | awk -F: '{print $2}' | sed 's#^[ \t]*##g')
  SYSTEM_CPU_NUMS=$(cat ${CPU_DIR} | grep 'model name' -c)
  SYSTEM_KERNEL=$(uname -a | awk '{print $3}')
  SYSTEM_IPADDR=$(hostname -I | awk '{print $1}')
  SYSTEM_HOSTNANE=$(hostname)
  # 输出系统信息
  log_info "${LINE}"
  log_info "${LINE}"
  echo "操作系统名称: ${SYSTEM_HOSTNANE}"
  echo "服务器IP地址: ${SYSTEM_IPADDR}"
  log_info "${LINE}"
  log_info "${LINE}"
  echo "操作系统版本: ${SYSTEM_VERSION}"
  echo "系统内核版本: ${SYSTEM_KERNEL}"
  echo "处理器的型号: ${SYSTEM_CPU}"
  echo "处理器的核数: ${SYSTEM_CPU_NUMS}"
  echo "系统当前时间: ${SYSTEM_DATE}"
  log_info "${LINE}"
  log_info "${LINE}"
}
#############################################################################################
# 测试是否可以访问公网
#############################################################################################
function CHECK_NETWORK() {
  PING_NUM=$(/usr/bin/ping -c 3 www.baidu.com | grep 'icmp_seq' -c)
  if [ "${PING_NUM}" -eq 0 ]; then
    log_error '网络连接失败，请先配置好网络连接...'
  fi
}

function CHECK_SYSTEM_OS() {
  VAR_SYSTEM_FLAG=$(/usr/bin/cat ${KERNEL_DIR} | grep 'CentOS' | grep '7' -c)
  if [ "${VAR_SYSTEM_FLAG}" -ne 1 ]; then
    log_error '只支持Centos操作系统.'
  fi
}

function CHECK_USER() {
  VAR_USER=$(/usr/bin/whoami)
  if [ "${VAR_USER}" != 'root' ]; then
    log_error '脚本目前只支持 [ root ] 用户执行，请先切换用户...'
  fi
}
function UPDATE_KERNEL() {
  # 设置内核安装源
  if rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm; then
     log_error "EL 源安装失败请检查！"
  fi
  # 查看可选升级版本
  yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
  KERNEL_NAME="kernel-lt"
  echo "请输入要安装的内核版本号(默认为lt版本) [lt/ml]: KERNEL_VERSION" && read -r KERNEL_VERSION
  if [ "${KERNEL_VERSION}" == "ml" ]; then
    KERNEL_NAME="kernel-ml"
  fi
  log_info "你选择升级的版本为: ${KERNEL_NAME}"
  # 升级内核
  if yum --enablerepo=elrepo-kernel install ${KERNEL_NAME}; then
    log_success "内核升级成功，请修改引导内核版本为新版本内核"
  else
    log_error "内核升级失败请检查！"
  fi
  # 查看系统已安装的内核版本
  log_info "当前系统已安装的内核版本如下："
  awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
  # 修改默认引导内核版本
  echo "请输入已升级的内核版本号：NEW_KERNEL_VERSION" && read -r NEW_KERNEL_VERSION
  if grub2-set-default "${NEW_KERNEL_VERSION}"; then
    log_success "默认引导内核版本修改成功，请重启服务器"
  else
    log_error "默认引导内核版本修改失败，请检查！"
  fi
}
PRINT_SYSTEM_INFO
CHECK_NETWORK
CHECK_SYSTEM_OS
CHECK_USER
UPDATE_KERNEL
