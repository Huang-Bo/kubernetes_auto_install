#!/bin/bash
###########################################################
### Description: Operating system optimization Scripts. ###
### Auther: Huang-Bo                                    ###
### Email: 17521365211@163.com                          ###
### Blog: https://blog.csdn.net/Habo_                   ###
### Create Date: 2022-07-14                             ###
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
echo -e "\033[33m############################# step 1. Character set display optimization. ############################# \033[0m"
#############################################################################################
# 调整语言环境为中文
#############################################################################################
echo 'LANG="en_US.UTF-8"' >/etc/locale.conf
# source /etc/locale.conf
echo ""
echo ""
#############################################################################################
# 文件描述符
#############################################################################################
cat >>/etc/security/limits.conf <<EOF
*           soft   nofile       65535
*           hard   nofile       65535
EOF
echo ""
echo ""
#############################################################################################
# 取消ctrl+alt+del
#############################################################################################
mv /usr/lib/systemd/system/ctrl-alt-del.target /usr/lib/systemd/system/ctrl-alt-del.target.bak
echo ""
echo ""
#############################################################################################
# SSH服务优化
#############################################################################################
date_time=$(date +"%Y-%m-%d-%H:%M:%S")
\cp /etc/ssh/sshd_config /etc/ssh/sshd_config."${date_time}"
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's%#PermitEmptyPasswords no%PermitEmptyPasswords no%g' /etc/ssh/sshd_config
service sshd restart
echo ""
echo ""
#############################################################################################
# 优化命令行界面
#############################################################################################
echo 'export PS1="[ \033[01;33m\u\033[0;36m@\033[01;34m\h \033[01;31m\w\033[0m ]\033[0m \n#"' >>/etc/profile
echo ""
echo ""
#############################################################################################
# 优化vim
#############################################################################################
cat >>/root/.vimrc <<EOF
syntax enable
syntax on
set ruler
set number
set cursorline
set cursorcolumn
set hlsearch
set incsearch
set ignorecase
set nocompatible
set wildmenu
set paste
set expandtab
set tabstop=2
set shiftwidth=4
set softtabstop=4
set gcr=a:block-blinkon0
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
highlight CursorLine   cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
EOF
echo -e "\033[33m############################# step 2. Kernel optimization. ############################# \033[0m"
#############################################################################################
# 内核参数优化
#############################################################################################
cat >>/etc/sysctl.conf <<EOF
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_fin_timeout = 30
vm.swappiness=1
vm.max_map_count = 262144
EOF
/sbin/sysctl -p
echo ""
echo ""
#############################################################################################
# k8s内核优化
#############################################################################################
cat <<EOF >/etc/sysctl.d/k8s.conf
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=10
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0 
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2
net.ipv4.ip_local_port_range= 45001 65000
net.ipv4.ip_forward=1
net.ipv4.tcp_max_tw_buckets=6000
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_synack_retries=2
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.netfilter.nf_conntrack_max=2310720
net.ipv6.neigh.default.gc_thresh1=8192
net.ipv6.neigh.default.gc_thresh2=32768
net.ipv6.neigh.default.gc_thresh3=65536
net.core.netdev_max_backlog=16384
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216
net.ipv4.tcp_max_syn_backlog = 8096 
net.core.somaxconn = 32768 
fs.inotify.max_user_instances=8192 
fs.inotify.max_user_watches=524288
fs.file-max=52706963
fs.nr_open=52706963
kernel.pid_max = 4194303
net.bridge.bridge-nf-call-arptables=1
vm.swappiness=0 
vm.overcommit_memory=1 
vm.panic_on_oom=0 
vm.max_map_count = 262144
EOF
sysctl --system
echo -e "\033[33m############################# step 3. Turn off firewall and swap partition and selinunx. ############################# \033[0m"
#############################################################################################
# 关闭selinux
#############################################################################################
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
echo ""
echo ""
#############################################################################################
# 关闭防火墙
#############################################################################################
systemctl stop firewalld && systemctl disable firewalld
echo ""
echo ""
#############################################################################################
# 关闭交换分区
#############################################################################################
swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
#############################################################################################
# 关闭不需要的服务
#############################################################################################
systemctl stop postfix.service && systemctl disable postfix.service
#############################################################################################
# 调整系统时区
#############################################################################################
timedatectl set-timezone Asia/Shanghai
timedatectl set-local-rtc 0
systemctl restart rsyslog.service crond.service
echo -e "\033[33m############################# step 4. config hosts file  ############################# \033[0m"
echo ""
echo ""
# IP=$(hostname -I | awk '{print $1}')
cat >>/etc/hosts <<EOF
192.168.1.200 k8s-master01
192.168.1.201 k8s-master02
192.168.1.202 k8s-master03
192.168.1.222 k8s-vip
192.168.1.101 k8s-node01
192.168.1.102 k8s-node02
192.168.1.103 k8s-node03
EOF


