####################################################
### Description: Kubernetes Auto Install Scripts.###
### Auther: Huang-Bo                             ###
### Email: haunbo@163.com                        ###
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

8.kubernetes Deployment Management Script

9.Usage:
./auto_install_k8s.sh [COMMAND] [ARGS...]
./auto_install_k8s.sh --help

10.Tips：
Execution sequence     Please execute the script in order and You need to replace the server address with your own 

