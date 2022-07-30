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
docker pull registry.cn-hangzhou.aliyuncs.com/kuber_repo/$imageName
done
