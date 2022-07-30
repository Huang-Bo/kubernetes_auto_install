#!/bin/bash
###############################################
### Description: k8s master init.           ###
### Auther: Huang-Bo                        ###
### Email: 17521365211@163.com              ###
### Blog: https://blog.csdn.net/Habo_       ###
### Create Date: 2022-07-17                 ###
###############################################
# 配置kubectl命令超级补全
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >>~/.bashrc
# 生成引导文件
kubeadm config print init-defaults >kubeadm-config.yaml
