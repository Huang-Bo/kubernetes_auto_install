#!/bin/bash
#######################################################
### Description: Create Administrative User Scripts ###
### Auther: Huang-Bo                                ###
### Email: 17521365211@163.com                      ###
### Blog: https://blog.csdn.net/Habo_               ###
### Create Date: 2022-07-14                         ###
#######################################################
echo -e "\033[33m############################# Create Ops Administrative User. ############################# \033[0m"
# 创建运维账号，并配置sudo权限
GROUP="/etc/group"
group_admin=$(cat ${GROUP} | grep admin -c)

if [ "$group_admin" -ge 1 ]; then
        echo "the group admin is already  "
else
        groupadd admin
        echo "%admin ALL=(ALL)  NOPASSWD: ALL" >>/etc/sudoers

        useradd ops -g admin
        echo "ops:Ops@1234" | chpasswd
fi
