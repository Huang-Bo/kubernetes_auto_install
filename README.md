####################################################
### Description: Kubernetes Auto Install Scripts.###
### Auther: Huang-Bo                             ###
### Email: 17521365211@163.com                   ###
### Blog: https://blog.csdn.net/Habo_            ###
### Create Date: 2022-07-13                      ###
####################################################
1. Initialize the operating system.
2. Install Docker and Configure Docker Mirror Acceleration.
3. Deploy high availability kubernetes cluster.
4. Master/Worker node Automatically join the cluster.
5. Network plugins  Calico|Flannel Choose one of the two.
6. podSubnet: 10.244.0.0/16   serviceSubnet: 10.96.0.0/12.
7. Ingress Version v1.1.0.

kubernetes Deployment Management Script
Usage: 
  ./auto_install_k8s.sh [COMMAND] [ARGS...]
  ./auto_install_k8s.sh --help

initialization：
  init                   Configure installation source 
                         Configure ansible 
                         Set password free 

Installation Commands: 
  install                Install kubernetes 
  pull                   Pull the image required by the kubernetes cluster 
  guide                  Boot kubernetes cluster 
  kubesk                 issue certificates individually 
  master_join            The master node joins the cluster 
  worker_join            Worker nodes join the cluster 
  flannel                install flannel plug-in 
  calico                 install calico  plug-in 
  ingress                install ingress plug-in 
  dashboard              install dashboard plug-in 
Tips：
  Execution sequence     Please execute the script in order and You need to replace the server address with your own 

