#!/bin/bash
####################################################
### Description: Kubernetes Auto Install Scripts.###
### Auther: Huang-Bo                             ###
### Email: haunbo@163.com                        ###
### Blog: https://blog.csdn.net/Habo_            ###
### Create Date: 2022-07-13                      ###
####################################################
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

function display()
{
echo -e "\033[33m###################### K8s Auto Install Scripts Description ###################### \033[0m"
echo -e "\033[32m#\033[0m"
echo -e "\033[32m# 1. Initialize the operating system. \033[0m"
echo -e "\033[32m# 2. Install Docker and Configure Docker Mirror Acceleration. \033[0m"
echo -e "\033[32m# 3. Deploy high availability kubernetes cluster. \033[0m"
echo -e "\033[32m# 4. Master/Worker node Automatically join the cluster \033[0m"
echo -e "\033[32m# 5. Network plugins  Calico|Flannel Choose one of the two. \033[0m"
echo -e "\033[32m# 6. podSubnet: 10.244.0.0/16   serviceSubnet: 10.96.0.0/12. \033[0m"
echo -e "\033[32m# 7. Ingress Version v1.1.0. \033[0m"
echo -e "\033[32m# Please note that this script deployment cluster scheme is not recommended for production environments \033[0m"
echo -e "\033[33m################################################################################## \033[0m"
echo ""
echo ""
}

#############################################################################################
# 获取系统信息并输出
#############################################################################################
function print_system_info() 
{
KERNEL_DIR="/etc/redhat-release"
CPU_DIR="/proc/cpuinfo"
LINE="*******************************************"
LINE1="=========================================="
log_info "${LINE}"
log_info "print system info."
log_info "${LINE}"
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

function replace_yum_source()
{
log_info "${LINE}"
log_info "configure local yum source."
log_info "${LINE}"
# 首先运行配置yum源脚本
echo "请先运行设置yum源脚本"
bash /kubernetes_auto_install/ansible_playbook/scripts/repo.sh
}

function configure_ansible()
{
log_info "${LINE}"
log_info "configure Ansible."
log_info "${LINE}"
#############################################################################################
# kubernetes master节点配置ansible作为集群管理机
#############################################################################################
yum -y install epel-release ansible
# 添加被管理端IP组
cat >>/etc/ansible/hosts <<EOF
[k8s_master]
192.168.1.200
[k8s_nodes]
192.168.1.101
192.168.1.102
EOF
#********************************************************************************************
# 可选操作，默认ansible远程用户为root用户                                                    ***
# 将远程用户设置为ops用户                                                                   ***
# sed -i  '10 a\remote_user=ops\n' /etc/ansible/ansible.cfg                               ***
# 开启普通用户提权参数                                                                      ***
# cat >> /etc/ansible/ansible.cfg << EOF                                                  ***
# [privilege_escalation]                                                                  ***
# become=True                                                                             ***
# become_method=sudo                                                                      ***
# become_user=root                                                                        ***
# become_ask_pass=False                                                                   ***
# [defaults]                                                                              ***
# remote_user=ops                                                                         ***
# EOF                                                                                     ***
#********************************************************************************************
}

#############################################################################################
action=$1
function usage() {
  echo "$(gettext 'kubernetes Deployment Management Script')"
  echo
  echo "Usage: "
  echo "  ./auto_install_k8s.sh [COMMAND] [ARGS...]"
  echo "  ./auto_install_k8s.sh --help"
  echo
  echo "initialization："
  echo "  init                   $(gettext 'Configure installation source ')"
  echo "                         $(gettext 'Configure ansible ')"
  echo "                         $(gettext 'Set password free ')"
  echo
  echo "Installation Commands: "
  echo "  install                $(gettext 'Install kubernetes ')"
  echo "  pull                   $(gettext 'Pull the image required by the kubernetes cluster ')"
  echo "  guide                  $(gettext 'Boot kubernetes cluster ')"
  echo "  guides                 $(gettext 'Boot HA kubernetes cluster ')"
  echo "  kubesk                 $(gettext 'issue certificates individually ')"
  echo "  master_join            $(gettext 'The master node joins the cluster ')"
  echo "  worker_join            $(gettext 'Worker nodes join the cluster ')"
  echo "  worker_joins           $(gettext 'Worker nodes join the  HA cluster ')"
  echo "  flannel                $(gettext 'install flannel plug-in ')"
  echo "  calico                 $(gettext 'install calico  plug-in ')"
  echo "  ingress                $(gettext 'install ingress plug-in ')"
  echo "  dashboard              $(gettext 'install dashboard plug-in ')"
  echo
  echo "Uninstall commands: "
  echo "  remove-flannel         $(gettext 'uninstall flannel plug-in ')"
  echo "  remove-calico          $(gettext 'uninstall calico  plug-in ')"
  echo "  remove-ingress         $(gettext 'uninstall ingress plug-in ')"
  echo "  remove-dashboard       $(gettext 'uninstall dashboard plug-in ')"
  echo
  echo "Tips："
  echo "  Execution sequence     $(gettext 'Please execute the script in order ')"
}

function secret_free_configuration()
{
log_info "${LINE}"
log_info "Configure Password Free Login."
log_info "${LINE}"
# 安装expect软件包及分发公钥
#############################################################################################
HOSTS_DIR="/kubernetes_auto_install/iplist.txt"
cat >${HOSTS_DIR} <<EOF
192.168.1.200 root redhat
192.168.1.101 root redhat
192.168.1.102 root redhat
EOF

# 判断密钥文件是否存在
if [ `ls -al /root/.ssh/ |grep id_rsa|wc -l` -eq 0 ]; then
ssh-keygen -t rsa -N '' <<EOF
/root/.ssh/id_rsa
yes
EOF
else
log_info "该机器中已存在id_rsa文件"
fi

yum -y install expect

while read host;do
        ip=$(echo "$host" |cut -d " " -f1)
        username=$(echo "$host" |cut -d " " -f2)
        password=$(echo "$host" |cut -d " " -f3)
expect <<EOF
        spawn ssh-copy-id -i $username@$ip
        expect {
               "yes/no" {send "yes\n";exp_continue}
               "password" {send "$password\n"}
        }
        expect eof
EOF
done < ${HOSTS_DIR}
log_info "${LINE}"
log_info "host $ip pub-key check"
log_info "${LINE}"
USERNAME="root"
HOSTS=$(cat ${HOSTS_DIR} | awk '{print $1}')
for ip in ${HOSTS}; do
        if ssh "$USERNAME"@"$ip" "echo ${HOSTNAME}"; then
                log_success "${ip} Connection successful."
        else
                log_error "${ip} connection failed."
        fi
done
}

function install_kubernetes()
{
log_info "${LINE}"
log_info "install kubernetes."
log_info "${LINE}"
# execute install kubernetes playbook.
ansible-playbook  /kubernetes_auto_install/ansible_playbook/file/install_kubernetes.yaml
log_info "${LINE}"
log_info "set ha cluster."
log_info "${LINE}"
# 配置集群高可用
#SCRIPT_DIR="/kubernetes_auto_install/k8s-master/"
#bash ${SCRIPT_DIR}haproxy-k8s-master/start-haproxy.sh
#bash ${SCRIPT_DIR}keepalived-k8s-master/start-keepalived.sh
#ansible-playbook -v /kubernetes_auto_install/ansible_playbook/file/kubernetes_ha.yaml
}

function pull_images()
{
log_info "${LINE}"
log_info "pull images."
log_info "${LINE}"
# 拉取引导集群所需镜像
images=(
kube-apiserver:v1.22.3
kube-proxy:v1.22.3
kube-controller-manager:v1.22.3
kube-scheduler:v1.22.3
coredns:1.8.4
etcd:3.5.0-0
pause:3.5
)
for imageName in ${images[@]} ; do
docker pull registry.aliyuncs.com/google_containers/$imageName
done
}
# 引导单master节点集群
function init_master()
{
# 使用kubeadm引导集群
log_info "${LINE}"
log_info "init main master."
log_info "${LINE}"
if kubeadm init --config=/kubernetes_auto_install/k8s-master/kubeadm-config.yaml;then
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   log_success "kubeadm init success"
else
   log_error "kubeadm init failed please check."
fi
}
# 引导高可用集群
function init_ha_master()
{
# 使用kubeadm引导集群
log_info "${LINE}"
log_info "init Multi master cluster."
log_info "${LINE}"
if kubeadm init --config=/kubernetes_auto_install/k8s-master/ha-kubeadm-config.yaml;then
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   log_success "kubeadm init success"
else
   log_error "kubeadm init failed please check."
fi
}

function kube_secret_key()
{
# 将主master节点上的证书文件copy到另外两台master节点
PKIDIR="/etc/kubernetes/pki/etcd/"
KUBEPKIDIR="/etc/kubernetes/pki/"
KUBEDIR="/etc/kubernetes/"
# 在另外两个节点下创建etcd目录
if ssh root@k8s-master02 "mkdir -p ${PKIDIR}";then
   # 分发至k8s-master02
   scp ${KUBEPKIDIR}ca.* root@k8s-master02:${KUBEPKIDIR}
   scp ${KUBEPKIDIR}sa.* root@k8s-master02:${KUBEPKIDIR}
   scp ${KUBEPKIDIR}front-proxy-ca.* root@k8s-master02:${KUBEPKIDIR}
   scp ${PKIDIR}ca.* root@k8s-master02:${PKIDIR}
   scp ${KUBEDIR}admin.conf root@k8s-master02:${KUBEDIR}
else
   log_error "master02服务器etcd目录创建失败"
fi

if ssh root@k8s-master03 "mkdir -p ${PKIDIR}";then
   # 分发至k8s-master02
   scp ${KUBEPKIDIR}ca.* root@k8s-master03:${KUBEPKIDIR}
   scp ${KUBEPKIDIR}sa.* root@k8s-master03:${KUBEPKIDIR}
   scp ${KUBEPKIDIR}front-proxy-ca.* root@k8s-master03:${KUBEPKIDIR}
   scp ${PKIDIR}ca.* root@k8s-master03:${PKIDIR}
   scp ${KUBEDIR}admin.conf root@k8s-master03:${KUBEDIR}
else
   log_error "master03服务器etcd目录创建失败"
fi
}

# }
# function get_token()
# {
# TOKEN=$(kubeadm token list | awk 'END{print $1}')
# HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
# }
function master_join_cluster()
{
TOKEN=$(kubeadm token list | awk 'END{print $1}')
HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
log_info "${LINE1}"
log_info "master join cluster."
log_info "${LINE1}"
# k8s-master02 join cluster.
if ssh root@k8s-master02  "kubeadm join 192.168.1.222:6444 --token ${TOKEN} --discovery-token-ca-cert-hash ${HASH} --control-plane";then
   log_success "k8s-master02 join cluster success."
   ssh root@k8s-master02 "mkdir -p $HOME/.kube"
   ssh root@k8s-master02 "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
   ssh root@k8s-master02 "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
else
   log_error "k8s-master02 join cluster failed."
fi
# k8s-master03 join cluster.
if ssh root@k8s-master03  "kubeadm join 192.168.1.222:6444 --token ${TOKEN} --discovery-token-ca-cert-hash ${HASH} --control-plane";then
   log_success "k8s-master03 join cluster success."
   ssh root@k8s-master03 "mkdir -p $HOME/.kube"
   ssh root@k8s-master03 "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
   ssh root@k8s-master03 "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
else
   log_error "k8s-master03 join cluster failed."
fi
}
# 加入多mater节点集群
function node_join_clusters () 
{
TOKEN=$(kubeadm token list | awk 'END{print $1}')
HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
log_info "${LINE1}"
log_info "node join Multi master cluster."
log_info "${LINE1}"
# k8s-node01 join cluster.
if ssh root@k8s-node01 "kubeadm join 192.168.1.222:6444--token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
   log_success "k8s-node01 Node has successfully joined the cluster" 
else
   log_error "k8s-node01 Node has falied joined the cluster"
fi
# k8s-node02 join cluster.
if ssh root@k8s-node02 "kubeadm join 192.168.1.222:6444 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
   log_success "k8s-node02 Node has successfully joined the cluster" 
else
   log_error "k8s-node02 Node has falied joined the cluster"
fi
k8s-node03 join cluster.
if ssh root@k8s-node03 "kubeadm join 192.168.1.222:6444 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
  log_success "k8s-node03 Node has successfully joined the cluster" 
else
  log_error "k8s-node03 Node has falied joined the cluster"
fi
}

# 加入单master节点集群
function node_join_cluster () 
{
TOKEN=$(kubeadm token list | awk 'END{print $1}')
HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
log_info "${LINE1}"
log_info "node join Single master cluster."
log_info "${LINE1}"
# k8s-node01 join cluster.
if ssh root@k8s-node01 "kubeadm join 192.168.1.200:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
   log_success "k8s-node01 Node has successfully joined the cluster" 
else
   log_error "k8s-node01 Node has falied joined the cluster"
fi
# k8s-node02 join cluster.
if ssh root@k8s-node02 "kubeadm join 192.168.1.200:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
   log_success "k8s-node02 Node has successfully joined the cluster" 
else
   log_error "k8s-node02 Node has falied joined the cluster"
fi
k8s-node03 join cluster.
if ssh root@k8s-node03 "kubeadm join 192.168.1.200:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${HASH}";then
  log_success "k8s-node03 Node has successfully joined the cluster" 
else
  log_error "k8s-node03 Node has falied joined the cluster"
fi
}

# 安装集群常用组件
function flannel_install()
{
kubectl apply -f /kubernetes_auto_install/k8s-master/plugins/flannel/kube-flannel.yml
}
function calico_install()
{
kubectl apply -f /kubernetes_auto_install/k8s-master/plugins/calico/calico.yaml
}
function ingress_install()
{
kubectl apply -f /kubernetes_auto_install/k8s-master/plugins/ingress/deploy.yaml
}
function dashboard_install()
{
kubectl apply -f /kubernetes_auto_install/k8s-master/plugins/dashboard/recommended.yaml
}

# 卸载集群组件
function flannel_uninstall()
{
kubectl delete -f /kubernetes_auto_install/k8s-master/plugins/flannel/kube-flannel.yml
}
function calico_uninstall()
{
kubectl delete -f /kubernetes_auto_install/k8s-master/plugins/calico/calico.yaml
}
function ingress_uninstall()
{
kubectl delete -f /kubernetes_auto_install/k8s-master/plugins/ingress/deploy.yaml
}
function dashboard_uninstall()
{
kubectl delete -f /kubernetes_auto_install/k8s-master/plugins/dashboard/recommended.yaml
}


if [[ "${action}" == "help" || "${action}" == "h" || "${action}" == "-h" || "${action}" == "--help" ]]; then
   usage
else
  case "${action}" in
  init)
    replace_yum_source
    configure_ansible
    secret_free_configuration
    ;;
  install)
    display
    print_system_info
    install_kubernetes
    ;;
  pull)
    pull_images
    ;;
  guide)
    init_master
    ;;
  guides)
    init_ha_master
    ;;
  kubesk)
    kube_secret_key
    ;;
  master_join)
    master_join_cluster
    ;;
  worker_join)
    node_join_cluster
    ;;
  worker_joins)
    node_join_clusters
    ;;
  flannel)
    flannel_install
    ;;
  calico)
    calico_install
    ;;
  ingress)
    ingress_install
    ;;
  dashboard)
    dashboard_install
    ;;     
  remove-flannel)
    flannel_uninstall
    ;;
  remove-calico)
    calico_uninstall
    ;;
  remove-ingress)
    ingress_uninstall
    ;;
  remove-dashboard)
    dashboard_uninstall
    ;;         
  *)
    echo "No such command: ${action}"
    usage
    ;;
  esac
fi
